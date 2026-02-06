import { Request, Response, NextFunction } from 'express';
import { MedidasService } from './medidas.service';

const medidasService = new MedidasService();

export class MedidasController {
    async getAll(_req: Request, res: Response, next: NextFunction) {
        try {
            const medidas = await medidasService.getAll();

            res.json({
                status: 'success',
                data: medidas,
            });
        } catch (error) {
            console.error('🔥 CRITICAL ERROR IN MEDIDAS CONTROLLER:', error);
            next(error);
        }
    }

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const medida = await medidasService.getById(id);

            res.json({
                status: 'success',
                data: medida,
            });
        } catch (error) {
            next(error);
        }
    }
}
