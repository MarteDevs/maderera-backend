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
}
