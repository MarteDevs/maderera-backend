import prisma from '../../../config/database';
import { CreateProductoInput, UpdateProductoInput } from './productos.schemas';
import { AppError } from '../../../middlewares/error.middleware';


export class ProductosService {
    async getAll(page: number, limit: number, search?: string) {
        const skip = (page - 1) * limit;

        const where = {
            deleted_at: null,
            ...(search
                ? {
                    OR: [
                        { nombre: { contains: search } }, // Case insensitive in default MySQL collation usually
                    ],
                }
                : {}),
        };

        const [productos, total] = await Promise.all([
            prisma.productos.findMany({
                where,
                include: {
                    medidas: {
                        select: { descripcion: true },
                    },
                    clasificaciones: {
                        select: { nombre: true },
                    },
                    producto_proveedores: {
                        where: { deleted_at: null, activo: true },
                        include: {
                            proveedores: { select: { nombre: true } },
                        },
                    },
                },
                skip,
                take: limit,
                orderBy: { nombre: 'asc' },
            }),
            prisma.productos.count({ where }),
        ]);

        return {
            data: productos,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getById(id: number) {
        const producto = await prisma.productos.findUnique({
            where: { id_producto: id },
            include: {
                medidas: true,
                clasificaciones: true,
                producto_proveedores: {
                    where: { deleted_at: null, activo: true },
                    include: {
                        proveedores: { select: { nombre: true } },
                    },
                },
            },
        });

        if (!producto || producto.deleted_at) {
            throw new AppError(404, 'Producto no encontrado');
        }

        return producto;
    }

    async create(data: CreateProductoInput & { proveedores?: any[] }, userId: number | undefined) {
        const username = userId ? (await prisma.usuarios.findUnique({ where: { id_usuario: userId } }))?.username : 'system';
        const proveedores = data.proveedores || [];
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        const { proveedores: _, ...productoData } = data;

        return await prisma.$transaction(async (tx) => {
            const producto = await tx.productos.create({
                data: {
                    ...productoData,
                    created_by: username,
                    updated_by: username,
                },
            });

            if (proveedores.length > 0) {
                await tx.producto_proveedores.createMany({
                    data: proveedores.map((p) => ({
                        id_producto: producto.id_producto,
                        id_proveedor: p.id_proveedor,
                        precio_compra_sugerido: p.precio_compra_sugerido,
                    })),
                });
            }

            return producto;
        });
    }

    async update(id: number, data: UpdateProductoInput & { proveedores?: any[] }, userId: number | undefined) {
        await this.getById(id); // Verifica existencia

        const username = userId ? (await prisma.usuarios.findUnique({ where: { id_usuario: userId } }))?.username : 'system';
        const proveedores = data.proveedores;
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        const { proveedores: _, ...productoData } = data;

        return await prisma.$transaction(async (tx) => {
            const producto = await tx.productos.update({
                where: { id_producto: id },
                data: {
                    ...productoData,
                    updated_at: new Date(),
                    updated_by: username,
                },
            });

            if (proveedores) {
                // Estrategia simple: Eliminar anteriores y crear nuevos (full replace)
                // Para mantener historial, lo ideal sería soft-delete o lógica de diff, pero por simplicidad MVP:
                await tx.producto_proveedores.deleteMany({
                    where: { id_producto: id },
                });

                if (proveedores.length > 0) {
                    await tx.producto_proveedores.createMany({
                        data: proveedores.map((p) => ({
                            id_producto: id,
                            id_proveedor: p.id_proveedor,
                            precio_compra_sugerido: p.precio_compra_sugerido,
                        })),
                    });
                }
            }

            return producto;
        });
    }

    async delete(id: number, userId: number | undefined) {
        await this.getById(id);

        const username = userId ? (await prisma.usuarios.findUnique({ where: { id_usuario: userId } }))?.username : 'system';

        // Soft delete
        return await prisma.productos.update({
            where: { id_producto: id },
            data: {
                deleted_at: new Date(),
                updated_at: new Date(),
                updated_by: username,
            },
        });
    }
}
