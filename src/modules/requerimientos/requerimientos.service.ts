import prisma from '../../config/database';
import { CreateRequerimientoInput, UpdateRequerimientoInput, UpdateEstadoInput } from './requerimientos.schemas';
import { AppError } from '../../middlewares/error.middleware';


export class RequerimientosService {
    async create(data: CreateRequerimientoInput, userId?: number) {
        return await prisma.$transaction(async (tx) => {
            // 1. Generar código usando SP
            // Usamos queryRawUnsafe para llamar al SP y obtener variable de sesión
            await tx.$executeRawUnsafe('CALL sp_generar_codigo_requerimiento(@codigo)');
            const result = await tx.$queryRawUnsafe<[{ codigo: string }]>('SELECT @codigo as codigo');

            const nuevoCodigo = result[0]?.codigo;

            if (!nuevoCodigo) {
                throw new AppError(500, 'Error al generar código de requerimiento');
            }

            // 2. Crear Cabecera
            const requerimiento = await tx.requerimientos.create({
                data: {
                    codigo: nuevoCodigo,
                    id_proveedor: data.id_proveedor,
                    id_mina: data.id_mina,
                    id_supervisor: data.id_supervisor,
                    observaciones: data.observaciones,
                    fecha_emision: data.fecha_emision,
                    fecha_prometida: data.fecha_prometida,
                    created_by: userId ? String(userId) : 'system',
                    requerimiento_detalles: {
                        create: data.detalles.map(det => ({
                            id_producto: det.id_producto,
                            cantidad_solicitada: det.cantidad_solicitada,
                            precio_proveedor: det.precio_proveedor,
                            precio_mina: det.precio_mina,
                            observacion: det.observacion,
                            created_by: userId ? String(userId) : 'system'
                        }))
                    }
                },
                include: {
                    requerimiento_detalles: true
                }
            });

            return requerimiento;
        });
    }

    async getAll(filters: any) {
        const page = Number(filters.page) || 1;
        const limit = Number(filters.limit) || 10;
        const skip = (page - 1) * limit;

        const where: any = {
            deleted_at: null
        };

        if (filters.id_proveedor) where.id_proveedor = filters.id_proveedor;
        if (filters.id_mina) where.id_mina = filters.id_mina;
        if (filters.estado) where.estado = filters.estado;
        if (filters.search) where.codigo = { contains: filters.search };

        if (filters.fecha_inicio && filters.fecha_fin) {
            where.fecha_emision = {
                gte: new Date(filters.fecha_inicio),
                lte: new Date(filters.fecha_fin)
            };
        }

        const [total, data] = await Promise.all([
            prisma.requerimientos.count({ where }),
            prisma.requerimientos.findMany({
                where,
                skip,
                take: limit,
                orderBy: { id_requerimiento: 'desc' },
                include: {
                    proveedores: { select: { nombre: true } },
                    minas: { select: { nombre: true } },
                    supervisores: { select: { nombre: true } },
                    _count: { select: { requerimiento_detalles: true } },
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
            })
        ]);

        return {
            data,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        };
    }

    async getById(id: number) {
        const requerimiento = await prisma.requerimientos.findUnique({
            where: { id_requerimiento: id },
            include: {
                proveedores: true,
                minas: true,
                supervisores: true,
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
        });

        if (!requerimiento) {
            throw new AppError(404, 'Requerimiento no encontrado');
        }

        return requerimiento;
    }

    async updateStatus(id: number, data: UpdateEstadoInput, userId?: number) {
        const existing = await this.getById(id);

        if (existing.estado === 'ANULADO') {
            throw new AppError(400, 'No se puede cambiar el estado de un requerimiento anulado');
        }

        return await prisma.requerimientos.update({
            where: { id_requerimiento: id },
            data: {
                estado: data.estado,
                motivo_anulacion: data.motivo_anulacion,
                updated_by: userId ? String(userId) : 'system'
            }
        });
    }

    async update(id: number, data: UpdateRequerimientoInput, userId?: number) {
        const existing = await this.getById(id);

        if (existing.estado !== 'PENDIENTE') {
            throw new AppError(400, 'Solo se pueden editar requerimientos en estado PENDIENTE');
        }

        return await prisma.requerimientos.update({
            where: { id_requerimiento: id },
            data: {
                ...data,
                updated_by: userId ? String(userId) : 'system'
            }
        });
    }
    async getProgress(id: number) {
        const requerimiento = await this.getById(id);
        const detalles = requerimiento.requerimiento_detalles;

        if (!detalles || detalles.length === 0) {
            return { porcentaje: 0, detalles: [] };
        }

        let totalSolicitado = 0;
        let totalEntregado = 0;

        const progresoDetalles = detalles.map(det => {
            const solicitado = det.cantidad_solicitada;
            const entregado = det.cantidad_entregada || 0;
            totalSolicitado += solicitado;
            totalEntregado += entregado;

            return {
                id_producto: det.id_producto,
                producto: det.productos.nombre,
                solicitado,
                entregado,
                porcentaje: Math.min(100, Math.round((entregado / solicitado) * 100))
            };
        });

        const porcentajeTotal = totalSolicitado > 0
            ? Math.min(100, Math.round((totalEntregado / totalSolicitado) * 100))
            : 0;

        return {
            id_requerimiento: id,
            codigo: requerimiento.codigo,
            estado: requerimiento.estado,
            porcentaje_total: porcentajeTotal,
            detalles: progresoDetalles
        };
    }
}
