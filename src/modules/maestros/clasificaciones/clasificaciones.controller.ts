import { Request, Response, NextFunction } from 'express';
import { ClasificacionesService } from './clasificaciones.service';

const clasificacionesService = new ClasificacionesService();

export class ClasificacionesController {
    async getAll(_req: Request, res: Response, next: NextFunction) {
        try {
            const clasificaciones = await clasificacionesService.getAll();

            res.json({
                status: 'success',
                data: clasificaciones,
            });
        } catch (error) {
            next(error);
        }
    }

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const clasificacion = await clasificacionesService.getById(id);

            res.json({
                status: 'success',
                data: clasificacion,
            });
        } catch (error) {
            next(error);
        }
    }
}
