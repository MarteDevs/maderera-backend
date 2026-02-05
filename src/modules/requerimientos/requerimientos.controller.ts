import { Request, Response, NextFunction } from 'express';
import { RequerimientosService } from './requerimientos.service';
import { createRequerimientoSchema, queryRequerimientoSchema, updateEstadoSchema, updateRequerimientoSchema } from './requerimientos.schemas';
import { AuthRequest } from '../../middlewares/auth.middleware';

const requerimientosService = new RequerimientosService();

export class RequerimientosController {
    async create(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const data = createRequerimientoSchema.parse(req.body);
            const result = await requerimientosService.create(data, req.user?.id_usuario);

            res.status(201).json({
                status: 'success',
                message: 'Requerimiento creado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const query = queryRequerimientoSchema.parse(req.query);
            const result = await requerimientosService.getAll(query.page, query.limit, query);

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
            const result = await requerimientosService.getById(id);

            res.json({
                status: 'success',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async updateStatus(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updateEstadoSchema.parse(req.body);
            const result = await requerimientosService.updateStatus(id, data, req.user?.id_usuario);

            res.json({
                status: 'success',
                message: 'Estado actualizado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async update(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updateRequerimientoSchema.parse(req.body);
            const result = await requerimientosService.update(id, data, req.user?.id_usuario);

            res.json({
                status: 'success',
                message: 'Requerimiento actualizado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }
}
