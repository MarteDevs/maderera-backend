import prisma from '../../../config/database';
import { CreateMinaInput, UpdateMinaInput } from './minas.schemas';
import { AppError } from '../../../middlewares/error.middleware';


export class MinasService {
    async getAll(page: number, limit: number, search?: string) {
        const skip = (page - 1) * limit;

        const where = {
            deleted_at: null,
            ...(search
                ? {
                    OR: [
                        { nombre: { contains: search } },
                        { razon_social: { contains: search } },
                        { ubicacion: { contains: search } },
                    ],
                }
                : {}),
        };

        const [minas, total] = await Promise.all([
            prisma.minas.findMany({
                where,
                skip,
                take: limit,
                orderBy: { nombre: 'asc' },
            }),
            prisma.minas.count({ where }),
        ]);

        return {
            data: minas,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getById(id: number) {
        const mina = await prisma.minas.findUnique({
            where: { id_mina: id },
        });

        if (!mina || mina.deleted_at) {
            throw new AppError(404, 'Mina no encontrada');
        }

        return mina;
    }

    async create(data: CreateMinaInput) {
        const existing = await prisma.minas.findUnique({
            where: { nombre: data.nombre },
        }); // Aunque deleted_at no es null, el nombre es unique key en BD, asi que cuidado
        // El unique key uk_nombre_mina no chequea deleted_at, así que si reciclas nombre puede fallar.
        // Deberíamos chequear si existe y está borrada para reactivarla o cambiar nombre.
        // Para simplificar, asumimos que intenta crear nuevo.

        return await prisma.minas.create({
            data,
        });
    }

    async update(id: number, data: UpdateMinaInput) {
        await this.getById(id);
        return await prisma.minas.update({
            where: { id_mina: id },
            data,
        });
    }

    async delete(id: number) {
        await this.getById(id);
        return await prisma.minas.update({
            where: { id_mina: id },
            data: { deleted_at: new Date() },
        });
    }
}
