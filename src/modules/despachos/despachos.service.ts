import prisma from '../../config/database';
import { Prisma } from '@prisma/client';
import type {
    CreateDespachoInput,
    UpdateDespachoInput,
    QueryDespachosInput,
    AnularDespachoInput
} from './despachos.schemas';

export class DespachosService {
    /**
     * Listar despachos con filtros y paginación
     */
    async list(query: QueryDespachosInput) {
        const { page, limit, estado, id_mina, id_viaje, fecha_desde, fecha_hasta, search } = query;

        const where: any = {};

        if (estado) where.estado = estado;
        if (id_mina) where.id_mina = id_mina;
        if (id_viaje) where.id_viaje = id_viaje;

        if (fecha_desde || fecha_hasta) {
            where.fecha_creacion = {};
            if (fecha_desde) where.fecha_creacion.gte = new Date(fecha_desde);
            if (fecha_hasta) where.fecha_creacion.lte = new Date(fecha_hasta);
        }

        if (search) {
            where.OR = [
                { codigo: { contains: search } },
                { observaciones: { contains: search } }
            ];
        }

        const [despachos, total] = await Promise.all([
            prisma.despachos.findMany({
                where,
                include: {
                    minas: { select: { nombre: true } },
                    supervisores: { select: { nombre: true } },
                    viajes: { select: { id_viaje: true, numero_viaje: true } },
                    despacho_detalles: {
                        include: {
                            productos: { select: { nombre: true } },
                            medidas: { select: { descripcion: true } }
                        }
                    }
                },
                orderBy: { fecha_creacion: 'desc' },
                skip: (page - 1) * limit,
                take: limit
            }),
            prisma.despachos.count({ where })
        ]);

        return {
            data: despachos,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        };
    }

    /**
     * Obtener un despacho por ID
     */
    async getById(id: number) {
        const despacho = await prisma.despachos.findUnique({
            where: { id_despacho: id },
            include: {
                minas: true,
                supervisores: true,
                viajes: true,
                despacho_detalles: {
                    include: {
                        productos: true,
                        medidas: true
                    }
                },
                movimientos_stock: {
                    include: {
                        productos: { select: { nombre: true } }
                    }
                }
            }
        });

        if (!despacho) {
            throw new Error('Despacho no encontrado');
        }

        return despacho;
    }

    /**
     * Crear un nuevo despacho en estado PREPARANDO
     */
    async create(data: CreateDespachoInput, usuario: string) {
        // Generar código único
        const ultimoDespacho = await prisma.despachos.findFirst({
            orderBy: { id_despacho: 'desc' },
            select: { id_despacho: true }
        });

        const numero = (ultimoDespacho?.id_despacho || 0) + 1;
        const codigo = `DSP-${new Date().getFullYear()}-${String(numero).padStart(4, '0')}`;

        // Crear despacho con detalles en una transacción
        const despacho = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const newDespacho = await tx.despachos.create({
                data: {
                    codigo,
                    id_mina: data.id_mina,
                    id_supervisor: data.id_supervisor,
                    id_viaje: data.id_viaje,
                    observaciones: data.observaciones,
                    estado: 'PREPARANDO',
                    created_by: usuario
                }
            });

            // Insertar detalles
            await tx.despacho_detalles.createMany({
                data: data.detalles.map(det => ({
                    id_despacho: newDespacho.id_despacho,
                    id_producto: det.id_producto,
                    id_medida: det.id_medida,
                    cantidad_despachada: det.cantidad_despachada,
                    observacion: det.observacion,
                    created_by: usuario
                }))
            });

            return newDespacho;
        });

        return this.getById(despacho.id_despacho);
    }

    /**
     * Actualizar un despacho (solo si está en PREPARANDO)
     */
    async update(id: number, data: UpdateDespachoInput, usuario: string) {
        const despacho = await this.getById(id);

        if (despacho.estado !== 'PREPARANDO') {
            throw new Error('Solo se pueden editar despachos en estado PREPARANDO');
        }

        return await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const updated = await tx.despachos.update({
                where: { id_despacho: id },
                data: {
                    id_mina: data.id_mina,
                    id_supervisor: data.id_supervisor,
                    id_viaje: data.id_viaje,
                    observaciones: data.observaciones,
                    updated_by: usuario
                }
            });

            // Si se envían nuevos detalles, reemplazar
            if (data.detalles) {
                // Eliminar detalles anteriores
                await tx.despacho_detalles.deleteMany({
                    where: { id_despacho: id }
                });

                // Insertar nuevos detalles
                await tx.despacho_detalles.createMany({
                    data: data.detalles.map(det => ({
                        id_despacho: id,
                        id_producto: det.id_producto,
                        id_medida: det.id_medida,
                        cantidad_despachada: det.cantidad_despachada,
                        observacion: det.observacion,
                        created_by: usuario
                    }))
                });
            }

            return updated;
        });
    }

    /**
     * Eliminar un despacho (solo si está en PREPARANDO)
     */
    async delete(id: number) {
        const despacho = await this.getById(id);

        if (despacho.estado !== 'PREPARANDO') {
            throw new Error('Solo se pueden eliminar despachos en estado PREPARANDO');
        }

        await prisma.despachos.delete({
            where: { id_despacho: id }
        });

        return { message: 'Despacho eliminado correctamente' };
    }

    /**
     * Cambiar despacho a EN_TRANSITO
     * Crea movimientos SALIDA en el kardex
     */
    async cambiarATransito(id: number, usuario: string, fecha_salida?: string) {
        const despacho = await prisma.despachos.findUnique({
            where: { id_despacho: id },
            include: {
                despacho_detalles: {
                    include: {
                        productos: { select: { nombre: true } }
                    }
                }
            }
        });

        if (!despacho) throw new Error('Despacho no encontrado');
        if (despacho.estado !== 'PREPARANDO') {
            throw new Error('Solo se pueden enviar a tránsito despachos en estado PREPARANDO');
        }

        // Validar stock disponible
        for (const detalle of despacho.despacho_detalles) {
            const stockActual = await prisma.$queryRaw<[{ stock_actual: number }]>`
                SELECT stock_actual FROM v_stock_actual 
                WHERE id_producto = ${detalle.id_producto} AND id_medida = ${detalle.id_medida}
            `;

            const stock = stockActual[0]?.stock_actual || 0;

            if (stock < detalle.cantidad_despachada) {
                throw new Error(
                    `Stock insuficiente para ${detalle.productos.nombre}. ` +
                    `Disponible: ${stock}, Requerido: ${detalle.cantidad_despachada}`
                );
            }
        }

        // Crear movimientos SALIDA y actualizar estado
        return await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            // Crear movimientos de stock SALIDA
            for (const detalle of despacho.despacho_detalles) {
                await tx.movimientos_stock.create({
                    data: {
                        id_producto: detalle.id_producto,
                        tipo: 'SALIDA',
                        cantidad: -Math.abs(detalle.cantidad_despachada), // Negativo para SALIDA
                        id_despacho: id,
                        usuario_registro: usuario,
                        observacion: `Despacho ${despacho.codigo} - Salida a mina`,
                        created_by: usuario
                    }
                });
            }

            // Actualizar estado del despacho
            return await tx.despachos.update({
                where: { id_despacho: id },
                data: {
                    estado: 'EN_TRANSITO',
                    fecha_salida: fecha_salida ? new Date(fecha_salida) : new Date(),
                    updated_by: usuario
                }
            });
        });
    }

    /**
     * Marcar despacho como ENTREGADO
     */
    async marcarEntregado(id: number, usuario: string, fecha_entrega?: string) {
        const despacho = await this.getById(id);

        if (despacho.estado !== 'EN_TRANSITO') {
            throw new Error('Solo se pueden entregar despachos en estado EN_TRANSITO');
        }

        return await prisma.despachos.update({
            where: { id_despacho: id },
            data: {
                estado: 'ENTREGADO',
                fecha_entrega: fecha_entrega ? new Date(fecha_entrega) : new Date(),
                updated_by: usuario
            }
        });
    }

    /**
     * Anular un despacho
     * Si estaba EN_TRANSITO o ENTREGADO, revierte el stock con AJUSTE_POS
     */
    async anular(id: number, data: AnularDespachoInput, usuario: string) {
        const despacho = await prisma.despachos.findUnique({
            where: { id_despacho: id },
            include: { despacho_detalles: true }
        });

        if (!despacho) throw new Error('Despacho no encontrado');
        if (despacho.estado === 'ANULADO') {
            throw new Error('El despacho ya está anulado');
        }

        return await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            // Si estaba EN_TRANSITO o ENTREGADO, revertir stock
            if (despacho.estado === 'EN_TRANSITO' || despacho.estado === 'ENTREGADO') {
                for (const detalle of despacho.despacho_detalles) {
                    await tx.movimientos_stock.create({
                        data: {
                            id_producto: detalle.id_producto,
                            tipo: 'AJUSTE_POS',
                            cantidad: Math.abs(detalle.cantidad_despachada), // Positivo para ajuste
                            usuario_registro: usuario,
                            observacion: `Reversión por anulación de despacho ${despacho.codigo}: ${data.motivo_anulacion}`,
                            created_by: usuario
                        }
                    });
                }
            }

            // Actualizar estado a ANULADO
            return await tx.despachos.update({
                where: { id_despacho: id },
                data: {
                    estado: 'ANULADO',
                    motivo_anulacion: data.motivo_anulacion,
                    updated_by: usuario
                }
            });
        });
    }
}

export const despachosService = new DespachosService();
