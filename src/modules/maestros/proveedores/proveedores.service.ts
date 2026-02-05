import prisma from '../../../config/database';
import { CreateProveedorInput, UpdateProveedorInput } from './proveedores.schemas';
import { AppError } from '../../../middlewares/error.middleware';


export class ProveedoresService {
    async getAll(page: number, limit: number, search?: string) {
        const skip = (page - 1) * limit;

        const where = {
            deleted_at: null,
            ...(search
                ? {
                    OR: [
                        { nombre: { contains: search } },
                        { razon_social: { contains: search } },
                        { ruc: { contains: search } },
                    ],
                }
                : {}),
        };

        const [proveedores, total] = await Promise.all([
            prisma.proveedores.findMany({
                where,
                skip,
                take: limit,
                orderBy: { nombre: 'asc' },
            }),
            prisma.proveedores.count({ where }),
        ]);

        return {
            data: proveedores,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getById(id: number) {
        const proveedor = await prisma.proveedores.findUnique({
            where: { id_proveedor: id },
        });

        if (!proveedor || proveedor.deleted_at) {
            throw new AppError(404, 'Proveedor no encontrado');
        }

        return proveedor;
    }

    async create(data: CreateProveedorInput) {
        // Validar RUC duplicado si existe
        if (data.ruc) {
            const existing = await prisma.proveedores.findFirst({
                where: { ruc: data.ruc, deleted_at: null },
            });
            if (existing) {
                throw new AppError(400, 'Ya existe un proveedor con este RUC');
            }
        }

        return await prisma.proveedores.create({
            data,
        });
    }

    async update(id: number, data: UpdateProveedorInput) {
        const proveedor = await this.getById(id);

        // Validar RUC duplicado si se está actualizando
        if (data.ruc && data.ruc !== proveedor.ruc) {
            const existing = await prisma.proveedores.findFirst({
                where: { ruc: data.ruc, deleted_at: null, NOT: { id_proveedor: id } },
            });
            if (existing) {
                throw new AppError(400, 'Ya existe un proveedor con este RUC');
            }
        }

        return await prisma.proveedores.update({
            where: { id_proveedor: id },
            data,
        });
    }

    async delete(id: number) {
        await this.getById(id);

        // Usar SP para eliminar (validado en BD) o soft delete manual
        // Por simplicidad y consistencia con lógica de negocio compleja, podríamos llamar al SP
        // o hacer el soft delete aquí. El SP `sp_soft_delete_proveedor` ya existe.

        // Opción A: Soft delete directo
        return await prisma.proveedores.update({
            where: { id_proveedor: id },
            data: { deleted_at: new Date() },
        });

        // Opción B: Llamar SP (mejor si hay lógica compleja de validación de deudas, etc)
        // await prisma.$executeRaw`CALL sp_soft_delete_proveedor(${id}, @mensaje)`;
    }
}
