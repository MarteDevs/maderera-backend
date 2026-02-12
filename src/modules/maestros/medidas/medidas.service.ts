import prisma from '../../../config/database';

export class MedidasService {
    async getAll() {
        const medidas = await prisma.medidas.findMany({
            where: {
                deleted_at: null,
            },
            orderBy: {
                descripcion: 'asc',
            },
        });

        return medidas;
    }

    async getById(id: number) {
        const medida = await prisma.medidas.findFirst({
            where: {
                id_medida: id,
                deleted_at: null,
            },
        });

        if (!medida) {
            throw new Error('Medida no encontrada');
        }

        return medida;
    }

    async create(data: { descripcion: string }) {
        // Valida si ya existe (opcional pero recomendado)
        const existing = await prisma.medidas.findFirst({
            where: {
                descripcion: data.descripcion,
                deleted_at: null,
            },
        });

        if (existing) {
            throw new Error('Ya existe una medida con esta descripción');
        }

        const medida = await prisma.medidas.create({
            data: {
                descripcion: data.descripcion,
            },
        });

        return medida;
    }
}
