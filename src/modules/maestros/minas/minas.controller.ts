import { Request, Response, NextFunction } from 'express';
import { MinasService } from './minas.service';
import { createMinaSchema, updateMinaSchema, queryMinaSchema } from './minas.schemas';

const minasService = new MinasService();

export class MinasController {
    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const query = queryMinaSchema.parse(req.query);
            const result = await minasService.getAll(query.page, query.limit, query.search);
            res.json({ status: 'success', data: result });
        } catch (error) { next(error); }
    }

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const result = await minasService.getById(id);
            res.json({ status: 'success', data: result });
        } catch (error) { next(error); }
    }

    async create(req: Request, res: Response, next: NextFunction) {
        try {
            const data = createMinaSchema.parse(req.body);
            const result = await minasService.create(data);
            res.status(201).json({ status: 'success', message: 'Mina creada', data: result });
        } catch (error) { next(error); }
    }

    async update(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updateMinaSchema.parse(req.body);
            const result = await minasService.update(id, data);
            res.json({ status: 'success', message: 'Mina actualizada', data: result });
        } catch (error) { next(error); }
    }

    async delete(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            await minasService.delete(id);
            res.json({ status: 'success', message: 'Mina eliminada' });
        } catch (error) { next(error); }
    }
}
