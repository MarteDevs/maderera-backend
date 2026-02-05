import { Request, Response, NextFunction } from 'express';
import { SupervisoresService } from './supervisores.service';
import { createSupervisorSchema, updateSupervisorSchema, querySupervisorSchema } from './supervisores.schemas';

const supervisoresService = new SupervisoresService();

export class SupervisoresController {
    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const query = querySupervisorSchema.parse(req.query);
            const result = await supervisoresService.getAll(query.page, query.limit, query.search);
            res.json({ status: 'success', data: result });
        } catch (error) { next(error); }
    }

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const result = await supervisoresService.getById(id);
            res.json({ status: 'success', data: result });
        } catch (error) { next(error); }
    }

    async create(req: Request, res: Response, next: NextFunction) {
        try {
            const data = createSupervisorSchema.parse(req.body);
            const result = await supervisoresService.create(data);
            res.status(201).json({ status: 'success', message: 'Supervisor creado', data: result });
        } catch (error) { next(error); }
    }

    async update(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updateSupervisorSchema.parse(req.body);
            const result = await supervisoresService.update(id, data);
            res.json({ status: 'success', message: 'Supervisor actualizado', data: result });
        } catch (error) { next(error); }
    }

    async delete(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            await supervisoresService.delete(id);
            res.json({ status: 'success', message: 'Supervisor eliminado' });
        } catch (error) { next(error); }
    }
}
