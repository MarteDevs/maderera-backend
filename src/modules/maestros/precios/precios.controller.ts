import { Request, Response, NextFunction } from 'express';
import { PreciosService } from './precios.service';
import { createPrecioSchema, updatePrecioSchema, queryPrecioSchema } from './precios.schemas';
import { AuthRequest } from '../../../middlewares/auth.middleware';

const preciosService = new PreciosService();

export class PreciosController {
    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const query = queryPrecioSchema.parse(req.query);
            const result = await preciosService.getAll(query.page, query.limit, {
                id_proveedor: query.id_proveedor,
                id_producto: query.id_producto,
                activo: query.activo,
            });

            res.json({ status: 'success', data: result });
        } catch (error) { next(error); }
    }

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const result = await preciosService.getById(id);

            res.json({ status: 'success', data: result });
        } catch (error) { next(error); }
    }

    async create(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const data = createPrecioSchema.parse(req.body);
            const result = await preciosService.create(data, req.user?.id_usuario);

            res.status(201).json({ status: 'success', message: 'Precio registrado', data: result });
        } catch (error) { next(error); }
    }

    async update(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updatePrecioSchema.parse(req.body);
            const result = await preciosService.update(id, data, req.user?.id_usuario);

            res.json({ status: 'success', message: 'Precio actualizado', data: result });
        } catch (error) { next(error); }
    }

    async delete(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            await preciosService.delete(id, req.user?.id_usuario);

            res.json({ status: 'success', message: 'Precio eliminado' });
        } catch (error) { next(error); }
    }
}
