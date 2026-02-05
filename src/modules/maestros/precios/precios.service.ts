import prisma from '../../../config/database';
import { CreatePrecioInput, UpdatePrecioInput } from './precios.schemas';
import { AppError } from '../../../middlewares/error.middleware';


export class PreciosService {
    async getAll(page: number, limit: number, filters: { id_proveedor?: number; id_producto?: number; activo?: boolean }) {
        const skip = (page - 1) * limit;

        const where = {
            deleted_at: null,
            ...(filters.id_proveedor ? { id_proveedor: filters.id_proveedor } : {}),
            ...(filters.id_producto ? { id_producto: filters.id_producto } : {}),
            ...(filters.activo !== undefined ? { activo: filters.activo } : {}),
        };

        const [precios, total] = await Promise.all([
            prisma.producto_proveedores.findMany({
                where,
                include: {
                    proveedores: { select: { nombre: true } },
                    productos: { select: { nombre: true, medidas: { select: { descripcion: true } } } },
                },
                skip,
                take: limit,
                orderBy: [{ id_proveedor: 'asc' }, { id_producto: 'asc' }],
            }),
            prisma.producto_proveedores.count({ where }),
        ]);

        return {
            data: precios,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getById(id: number) {
        const precio = await prisma.producto_proveedores.findUnique({
            where: { id_catalogo: id },
            include: {
                proveedores: true,
                productos: true,
                precio_historico: {
                    orderBy: { fecha_cambio: 'desc' },
                    take: 10,
                },
            },
        });

        if (!precio || precio.deleted_at) {
            throw new AppError(404, 'Registro de precio no encontrado');
        }

        return precio;
    }

    async create(data: CreatePrecioInput, userId: number | undefined) {
        // Validar duplicado
        const existing = await prisma.producto_proveedores.findUnique({
            where: {
                id_proveedor_id_producto: {
                    id_proveedor: data.id_proveedor,
                    id_producto: data.id_producto,
                },
            },
        });

        if (existing) {
            if (existing.deleted_at) {
                // Reactivar
                return await prisma.producto_proveedores.update({
                    where: { id_catalogo: existing.id_catalogo },
                    data: {
                        deleted_at: null,
                        precio_compra_sugerido: data.precio_compra_sugerido,
                        activo: data.activo ?? true,
                        updated_at: new Date(),
                    },
                });
            }
            throw new AppError(400, 'Ya existe un precio para este producto y proveedor');
        }

        const username = userId ? (await prisma.usuarios.findUnique({ where: { id_usuario: userId } }))?.username : 'system';

        return await prisma.producto_proveedores.create({
            data: {
                ...data,
                created_by: username,
                updated_by: username,
            },
        });
    }

    async update(id: number, data: UpdatePrecioInput, userId: number | undefined) {
        const precioActual = await this.getById(id);
        const username = userId ? (await prisma.usuarios.findUnique({ where: { id_usuario: userId } }))?.username : 'system';

        // Si cambió el precio, registrar en histórico (si no hay trigger)
        // Asumimos que la BD tiene un trigger o lo manejamos aquí. 
        // Dado que el usuario vio "trg_precio_cambio" en el análisis, confiamos en la BD para la auditoría,
        // pero `precio_historico` es una tabla específica.
        // El trigger `trg_precio_cambio` probablemente inserta en `auditoria`, pero `precio_historico` es otra tabla.
        // Revisemos si hay lógica manual necesaria. 
        // Para asegurar, lo hacemos acá también si el precio cambia.

        if (data.precio_compra_sugerido !== undefined && data.precio_compra_sugerido !== Number(precioActual.precio_compra_sugerido)) {
            await prisma.precio_historico.create({
                data: {
                    id_catalogo: id,
                    precio_anterior: precioActual.precio_compra_sugerido,
                    precio_nuevo: data.precio_compra_sugerido,
                    usuario_cambio: username,
                },
            });
        }

        return await prisma.producto_proveedores.update({
            where: { id_catalogo: id },
            data: {
                ...data,
                updated_at: new Date(),
                updated_by: username,
            },
        });
    }

    async delete(id: number, userId: number | undefined) {
        const username = userId ? (await prisma.usuarios.findUnique({ where: { id_usuario: userId } }))?.username : 'system';

        return await prisma.producto_proveedores.update({
            where: { id_catalogo: id },
            data: {
                deleted_at: new Date(),
                updated_at: new Date(),
                updated_by: username,
            },
        });
    }
}
