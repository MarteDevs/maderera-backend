import { Request, Response, NextFunction } from 'express';
import { ProveedoresService } from './proveedores.service';
import { createProveedorSchema, updateProveedorSchema, queryProveedorSchema } from './proveedores.schemas';

const proveedoresService = new ProveedoresService();

export class ProveedoresController {
    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const query = queryProveedorSchema.parse(req.query);
            const result = await proveedoresService.getAll(query.page, query.limit, query.search);

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
            const result = await proveedoresService.getById(id);

            res.json({
                status: 'success',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async create(req: Request, res: Response, next: NextFunction) {
        try {
            const data = createProveedorSchema.parse(req.body);
            const result = await proveedoresService.create(data);

            res.status(201).json({
                status: 'success',
                message: 'Proveedor creado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async update(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updateProveedorSchema.parse(req.body);
            const result = await proveedoresService.update(id, data);

            res.json({
                status: 'success',
                message: 'Proveedor actualizado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async delete(req: Request, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            await proveedoresService.delete(id);

            res.json({
                status: 'success',
                message: 'Proveedor eliminado exitosamente',
            });
        } catch (error) {
            next(error);
        }
    }
}
