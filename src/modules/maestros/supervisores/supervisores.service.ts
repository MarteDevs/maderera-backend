import prisma from '../../../config/database';
import { CreateSupervisorInput, UpdateSupervisorInput } from './supervisores.schemas';
import { AppError } from '../../../middlewares/error.middleware';


export class SupervisoresService {
    async getAll(page: number, limit: number, search?: string) {
        const skip = (page - 1) * limit;

        const where = {
            deleted_at: null,
            ...(search
                ? {
                    OR: [
                        { nombre: { contains: search } },
                        { email: { contains: search } },
                    ],
                }
                : {}),
        };

        const [supervisores, total] = await Promise.all([
            prisma.supervisores.findMany({
                where,
                skip,
                take: limit,
                orderBy: { nombre: 'asc' },
            }),
            prisma.supervisores.count({ where }),
        ]);

        return {
            data: supervisores,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getById(id: number) {
        const supervisor = await prisma.supervisores.findUnique({
            where: { id_supervisor: id },
        });

        if (!supervisor || supervisor.deleted_at) {
            throw new AppError(404, 'Supervisor no encontrado');
        }

        return supervisor;
    }

    async create(data: CreateSupervisorInput) {
        return await prisma.supervisores.create({ data });
    }

    async update(id: number, data: UpdateSupervisorInput) {
        await this.getById(id);
        return await prisma.supervisores.update({
            where: { id_supervisor: id },
            data,
        });
    }

    async delete(id: number) {
        await this.getById(id);
        return await prisma.supervisores.update({
            where: { id_supervisor: id },
            data: { deleted_at: new Date() },
        });
    }
}
