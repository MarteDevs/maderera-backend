import prisma from '../../../config/database';

export class ClasificacionesService {
    async getAll() {
        const clasificaciones = await prisma.clasificaciones.findMany({
            where: {
                deleted_at: null,
                activo: true,
            },
            orderBy: {
                nombre: 'asc',
            },
        });

        return clasificaciones;
    }

    async getById(id: number) {
        const clasificacion = await prisma.clasificaciones.findFirst({
            where: {
                id_clasificacion: id,
                deleted_at: null,
            },
        });

        if (!clasificacion) {
            throw new Error('Clasificación no encontrada');
        }

        return clasificacion;
    }
}
