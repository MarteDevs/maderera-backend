import prisma from '../../config/database';
import { CreateViajeInput } from './viajes.schemas';
import { AppError } from '../../middlewares/error.middleware';

export class ViajesService {
    async getAll(page: number, limit: number) {
        const skip = (page - 1) * limit;
        const [viajes, total] = await Promise.all([
            prisma.viajes.findMany({
                skip,
                take: limit,
                orderBy: { fecha_ingreso: 'desc' },
                include: {
                    requerimientos: {
                        select: {
                            codigo: true,
                            proveedores: { select: { nombre: true } }
                        }
                    }
                }
            }),
            prisma.viajes.count()
        ]);

        return {
            data: viajes,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        };
    }

    async create(data: CreateViajeInput, _userId?: number, username?: string) {
        return await prisma.$transaction(async (tx) => {
            // 1. Validar Requerimiento
            const requerimiento = await tx.requerimientos.findUnique({
                where: { id_requerimiento: data.id_requerimiento }
            });

            if (!requerimiento) {
                throw new AppError(404, 'Requerimiento no encontrado');
            }

            if (requerimiento.estado === 'ANULADO') {
                throw new AppError(400, 'No se pueden registrar viajes para un requerimiento ANULADO');
            }

            // 2. Registrar Cabecera de Viaje usando SP
            // sp_registrar_viaje(IN p_id_req, IN p_placa, IN p_conductor, IN p_usuario, OUT p_id_viaje)

            // Preparamos las variables para el raw query
            // Nota: Prisma raw query parameters are strictly positional or handled via binding.
            // Para output parameters, la mejor estrategia es usar variables de sesión SQL.

            const usuario = username || 'system';

            // Ejecutamos el CALL
            await tx.$executeRawUnsafe(
                `CALL sp_registrar_viaje(?, ?, ?, ?, @id_viaje)`,
                data.id_requerimiento,
                data.placa_vehiculo,
                data.conductor,
                usuario
            );

            // Recuperamos el ID generado
            const result = await tx.$queryRawUnsafe<[{ id_viaje: number }]>('SELECT @id_viaje as id_viaje');
            const idViaje = result[0]?.id_viaje;

            if (!idViaje) {
                throw new AppError(500, 'Error al registrar el viaje en base de datos');
            }

            // 3. Registrar Detalles
            // Mapeamos los detalles para createMany
            const detallesData = data.detalles.map(det => ({
                id_viaje: Number(idViaje),
                id_detalle_requerimiento: det.id_detalle_requerimiento,
                cantidad_recibida: det.cantidad_recibida,
                estado_entrega: det.estado_entrega,
                observacion: det.observacion,
                created_by: usuario
            }));

            await tx.viaje_detalles.createMany({
                data: detallesData
            });

            return { id_viaje: Number(idViaje), message: 'Viaje registrado exitosamente' };
        });
    }

    async getByRequerimiento(idRequerimiento: number) {
        return await prisma.viajes.findMany({
            where: { id_requerimiento: idRequerimiento },
            include: {
                viaje_detalles: true
            },
            orderBy: { numero_viaje: 'asc' }
        });
    }

    async getById(id: number) {
        const viaje = await prisma.viajes.findUnique({
            where: { id_viaje: id },
            include: {
                requerimientos: {
                    include: {
                        proveedores: { select: { nombre: true } }
                    }
                },
                viaje_detalles: true
            }
        });

        if (!viaje) {
            throw new AppError(404, 'Viaje no encontrado');
        }

        return viaje;
    }
}
