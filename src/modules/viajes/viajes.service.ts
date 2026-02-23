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

        // Filtro por Mes y Año (Prioridad sobre rango de fechas manual)
        if (filters.mes && filters.anio) {
            const start = new Date(filters.anio, filters.mes - 1, 1);
            const end = new Date(filters.anio, filters.mes, 0, 23, 59, 59, 999);
            where.fecha_ingreso = { gte: start, lte: end };
        } else if (filters.anio) {
            const start = new Date(filters.anio, 0, 1);
            const end = new Date(filters.anio, 11, 31, 23, 59, 59, 999);
            where.fecha_ingreso = { gte: start, lte: end };
        } else if (filters.fecha_inicio && filters.fecha_fin) {
            const start = new Date(filters.fecha_inicio);
            start.setHours(0, 0, 0, 0);
            const end = new Date(filters.fecha_fin);
            end.setHours(23, 59, 59, 999);
            where.fecha_ingreso = { gte: start, lte: end };
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
                            minas: { select: { nombre: true } }
                        }
                    },
                    viaje_detalles: {
                        include: {
                            requerimiento_detalles: {
                                include: {
                                    productos: { include: { medidas: true } }
                                }
                            },
                            // Extra item relations
                            productos: { select: { nombre: true } },
                            medidas: { select: { descripcion: true } }
                        } as any
                    }
                }
            }),
            prisma.viajes.count({ where })
        ]);

        return {
            data: viajes,
            pagination: { page, limit, total, totalPages: Math.ceil(total / limit) }
        };
    }

    async create(data: CreateViajeInput, _userId?: number, username?: string) {
        return await prisma.$transaction(async (tx) => {
            // 1. Validar Requerimiento
            const requerimiento = await tx.requerimientos.findUnique({
                where: { id_requerimiento: data.id_requerimiento },
                include: { requerimiento_detalles: true }
            });

            if (!requerimiento) throw new AppError(404, 'Requerimiento no encontrado');
            if (requerimiento.estado === 'ANULADO') {
                throw new AppError(400, 'No se pueden registrar viajes para un requerimiento ANULADO');
            }

            const usuario = username || 'system';

            // 2. Registrar Viaje con SP
            await tx.$executeRawUnsafe(
                `CALL sp_registrar_viaje(?, ?, ?, ?, ?, ?, @id_viaje)`,
                data.id_requerimiento,
                data.placa_vehiculo,
                data.conductor,
                data.numero_vale || null,
                usuario,
                data.fecha_ingreso ? new Date(data.fecha_ingreso) : null
            );

            const result = await tx.$queryRawUnsafe<[{ id_viaje: number }]>('SELECT @id_viaje as id_viaje');
            const idViaje = result[0]?.id_viaje;

            if (!idViaje) throw new AppError(500, 'Error al registrar el viaje en base de datos');

            // 3. Actualizar etiqueta_viaje si existe
            if (data.etiqueta_viaje) {
                await tx.viajes.update({
                    where: { id_viaje: Number(idViaje) },
                    data: { etiqueta_viaje: data.etiqueta_viaje }
                });
            }

            // 4. Separar detalles normales y extras
            const detallesNormales = data.detalles.filter(d => !d.es_extra) as any[];
            const detallesExtras = data.detalles.filter(d => d.es_extra) as any[];

            // 5. Insertar detalles normales (vinculados al requerimiento)
            if (detallesNormales.length > 0) {
                await tx.viaje_detalles.createMany({
                    data: detallesNormales.map(det => ({
                        id_viaje: Number(idViaje),
                        id_detalle_requerimiento: det.id_detalle_requerimiento,
                        es_extra: false,
                        cantidad_recibida: det.cantidad_recibida,
                        estado_entrega: det.estado_entrega,
                        observacion: det.observacion,
                        created_by: usuario
                    }))
                });
            }

            // 6. Insertar detalles extras (productos no solicitados)
            if (detallesExtras.length > 0) {
                await tx.viaje_detalles.createMany({
                    data: detallesExtras.map((det: any) => ({
                        id_viaje: Number(idViaje),
                        id_detalle_requerimiento: undefined,
                        es_extra: true,
                        id_producto: det.id_producto,
                        id_medida: det.id_medida,
                        cantidad_recibida: det.cantidad_recibida,
                        estado_entrega: det.estado_entrega || 'OK',
                        observacion: det.observacion,
                        created_by: usuario
                    })) as any
                });
            }

            // 7. Actualizar estado del Requerimiento según las cantidades recibidas
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
            if (totalEntregado >= totalSolicitado) nuevoEstado = 'COMPLETADO';
            else if (totalEntregado === 0) nuevoEstado = 'PENDIENTE';

            if (nuevoEstado !== requerimiento.estado) {
                await tx.requerimientos.update({
                    where: { id_requerimiento: data.id_requerimiento },
                    data: { estado: nuevoEstado as any }
                });
            }

            return {
                id_viaje: Number(idViaje),
                message: `Viaje registrado. Estado Requerimiento: ${nuevoEstado}`,
                extras_registrados: detallesExtras.length
            };
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
                                productos: { include: { medidas: true } }
                            }
                        },
                        productos: { select: { nombre: true } },
                        medidas: { select: { descripcion: true } }
                    } as any
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
                    include: { proveedores: { select: { nombre: true } } }
                },
                viaje_detalles: {
                    include: {
                        requerimiento_detalles: {
                            include: {
                                productos: { include: { medidas: true } }
                            }
                        },
                        productos: { select: { nombre: true } },
                        medidas: { select: { descripcion: true } }
                    } as any
                }
            }
        });

        if (!viaje) throw new AppError(404, 'Viaje no encontrado');
        return viaje;
    }
}
