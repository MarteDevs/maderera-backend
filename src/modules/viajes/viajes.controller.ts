import { Request, Response, NextFunction } from 'express';
import { ViajesService } from './viajes.service';
import { createViajeSchema } from './viajes.schemas';
import { AuthRequest } from '../../middlewares/auth.middleware';

const viajesService = new ViajesService();

export class ViajesController {
    async create(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const data = createViajeSchema.parse(req.body);
            // Pasamos ID y username para auditoría
            const userId = req.user?.id_usuario;
            const username = req.user?.username;

            const result = await viajesService.create(data, userId, username);

            res.status(201).json({
                status: 'success',
                message: 'Viaje registrado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async getByRequerimiento(req: Request, res: Response, next: NextFunction) {
        try {
            const idRequerimiento = parseInt(req.params.id_requerimiento);
            if (isNaN(idRequerimiento)) {
                return res.status(400).json({ status: 'error', message: 'ID de requerimiento inválido' });
            }

            const result = await viajesService.getByRequerimiento(idRequerimiento);

            res.json({
                status: 'success',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const result = await viajesService.getById(id);

            res.json({
                status: 'success',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }
}
