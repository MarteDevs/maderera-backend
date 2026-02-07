import prisma from '../../config/database';
import { CreateViajeInput, QueryViajeInput } from './viajes.schemas';
import { AppError } from '../../middlewares/error.middleware';

export class ViajesService {
    async getAll(filters: QueryViajeInput) {
        const page = filters.page;
        const limit = filters.limit;
        const skip = (page - 1) * limit;

        const where: any = {};

        if (filters.id_requerimiento) where.id_requerimiento = filters.id_requerimiento;

        // Relaciones con Requerimiento (Proveedor y Mina)
        if (filters.id_proveedor || filters.id_mina) {
            where.requerimientos = {};
            if (filters.id_proveedor) where.requerimientos.id_proveedor = filters.id_proveedor;
            if (filters.id_mina) where.requerimientos.id_mina = filters.id_mina;
        }

        // Búsqueda por texto (Placa o Conductor)
        if (filters.search) {
            where.OR = [
                { placa_vehiculo: { contains: filters.search } },
                { conductor: { contains: filters.search } }
            ];
        }

        // Rango de Fechas
        if (filters.fecha_inicio && filters.fecha_fin) {
            const start = new Date(filters.fecha_inicio);
            start.setHours(0, 0, 0, 0);
            const end = new Date(filters.fecha_fin);
            end.setHours(23, 59, 59, 999);

            where.fecha_ingreso = {
                gte: start,
                lte: end
            };
        }

        const [viajes, total] = await Promise.all([
            prisma.viajes.findMany({
                where,
                skip,
                take: limit,
                orderBy: { fecha_ingreso: 'desc' },
                include: {
                    requerimientos: {
                        select: {
                            codigo: true,
                            proveedores: { select: { nombre: true } },
                            minas: { select: { nombre: true } } // Agregamos nombre de la mina
                        }
                    },
                    viaje_detalles: {
                        include: {
                            requerimiento_detalles: {
                                include: {
                                    productos: {
                                        include: {
                                            medidas: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }),
            prisma.viajes.count({ where })
        ]);

        return {
            data: viajes,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        };
    }

    async create(data: CreateViajeInput, _userId?: number, username?: string) {
        // ... existing create logic ...
        return await prisma.$transaction(async (tx) => {
            // 1. Validar Requerimiento y obtener sus detalles para mapear productos
            const requerimiento = await tx.requerimientos.findUnique({
                where: { id_requerimiento: data.id_requerimiento },
                include: { requerimiento_detalles: true }
            });

            if (!requerimiento) {
                throw new AppError(404, 'Requerimiento no encontrado');
            }

            if (requerimiento.estado === 'ANULADO') {
                throw new AppError(400, 'No se pueden registrar viajes para un requerimiento ANULADO');
            }

            const usuario = username || 'system';

            // Insertar Viaje usando SP (mantiene lógica de numero_viaje)
            await tx.$executeRawUnsafe(
                `CALL sp_registrar_viaje(?, ?, ?, ?, @id_viaje)`,
                data.id_requerimiento,
                data.placa_vehiculo,
                data.conductor,
                usuario
            );

            const result = await tx.$queryRawUnsafe<[{ id_viaje: number }]>('SELECT @id_viaje as id_viaje');
            const idViaje = result[0]?.id_viaje;

            if (!idViaje) {
                throw new AppError(500, 'Error al registrar el viaje en base de datos');
            }

            // Preparar datos para Viaje Detalles
            const detallesData = data.detalles.map(det => ({
                id_viaje: Number(idViaje),
                id_detalle_requerimiento: det.id_detalle_requerimiento,
                cantidad_recibida: det.cantidad_recibida,
                estado_entrega: det.estado_entrega,
                observacion: det.observacion,
                created_by: usuario
            }));

            // Insertar Detalles del Viaje
            await tx.viaje_detalles.createMany({
                data: detallesData
            });

            // 2. Insertar Movimientos de Stock (Kardex) y Actualizar Stock Actual
            // Esto también podría disparar triggers, pero aseguramos el registro en Kardex
            const movimientosData = [];

            for (const det of data.detalles) {
                // Buscar el id_producto correspondiente al detalle del requerimiento
                const reqDetalle = requerimiento.requerimiento_detalles.find(rd => rd.id_detalle === det.id_detalle_requerimiento);

                if (reqDetalle && det.cantidad_recibida > 0 && det.estado_entrega === 'OK') {
                    movimientosData.push({
                        id_producto: reqDetalle.id_producto,
                        tipo: 'ENTRADA', // Enum hardcoded based on schemas
                        cantidad: det.cantidad_recibida,
                        id_viaje: Number(idViaje),
                        id_requerimiento: data.id_requerimiento,
                        id_detalle_req: det.id_detalle_requerimiento,
                        observacion: `Recepción Viaje #${idViaje} - ${det.observacion || ''}`,
                        usuario_registro: usuario,
                        created_by: usuario
                    });
                }
            }

            if (movimientosData.length > 0) {
                await tx.movimientos_stock.createMany({
                    data: movimientosData as any // Cast to avoid strict enum typing issues if types aren't perfectly aligned
                });
            }

            // 3. Verificar y Actualizar Estado del Requerimiento
            // Recalcular cantidades entregadas (sumando lo actual + lo nuevo ya insertado por triggers o lógica)
            // Nota: Los triggers en 'viaje_detalles' ya deberían haber actualizado 'cantidad_entregada' en 'requerimiento_detalles'.
            // Consultamos de nuevo los detalles actualizados para verificar el estado global.

            const reqDetallesActualizados = await tx.requerimiento_detalles.findMany({
                where: { id_requerimiento: data.id_requerimiento }
            });

            let totalSolicitado = 0;
            let totalEntregado = 0;

            reqDetallesActualizados.forEach(d => {
                totalSolicitado += d.cantidad_solicitada;
                totalEntregado += (d.cantidad_entregada || 0);
            });

            let nuevoEstado = 'PARCIAL';
            if (totalEntregado >= totalSolicitado) {
                nuevoEstado = 'COMPLETADO';
            } else if (totalEntregado === 0) {
                nuevoEstado = 'PENDIENTE';
            }

            if (nuevoEstado !== requerimiento.estado) {
                await tx.requerimientos.update({
                    where: { id_requerimiento: data.id_requerimiento },
                    data: { estado: nuevoEstado as any }
                });
            }

            return { id_viaje: Number(idViaje), message: `Viaje registrado. Estado Requerimiento: ${nuevoEstado}` };
        });
    }

    async getByRequerimiento(idRequerimiento: number) {
        return await prisma.viajes.findMany({
            where: { id_requerimiento: idRequerimiento },
            include: {
                viaje_detalles: {
                    include: {
                        requerimiento_detalles: {
                            include: {
                                productos: {
                                    include: {
                                        medidas: true
                                    }
                                }
                            }
                        }
                    }
                }
            },
            orderBy: { numero_viaje: 'asc' }
        });
    }

    async getById(id: number) {
        const viaje = await prisma.viajes.findUnique({
            where: { id_viaje: id },
            include: {
                requerimientos: {
                    include: {
                        proveedores: { select: { nombre: true } }
                    }
                },
                viaje_detalles: {
                    include: {
                        requerimiento_detalles: {
                            include: {
                                productos: {
                                    include: {
                                        medidas: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        });

        if (!viaje) {
            throw new AppError(404, 'Viaje no encontrado');
        }

        return viaje;
    }
}
