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
