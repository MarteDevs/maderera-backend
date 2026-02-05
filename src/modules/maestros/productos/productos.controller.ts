import { Request, Response, NextFunction } from 'express';
import { ProductosService } from './productos.service';
import { createProductoSchema, updateProductoSchema, queryProductoSchema } from './productos.schemas';
import { AuthRequest } from '../../../middlewares/auth.middleware';

const productosService = new ProductosService();

export class ProductosController {
    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const query = queryProductoSchema.parse(req.query);
            const result = await productosService.getAll(query.page, query.limit, query.search);

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
            const result = await productosService.getById(id);

            res.json({
                status: 'success',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async create(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const data = createProductoSchema.parse(req.body);
            const result = await productosService.create(data, req.user?.id_usuario);

            res.status(201).json({
                status: 'success',
                message: 'Producto creado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async update(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updateProductoSchema.parse(req.body);
            const result = await productosService.update(id, data, req.user?.id_usuario);

            res.json({
                status: 'success',
                message: 'Producto actualizado exitosamente',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async delete(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            await productosService.delete(id, req.user?.id_usuario);

            res.json({
                status: 'success',
                message: 'Producto eliminado exitosamente',
            });
        } catch (error) {
            next(error);
        }
    }
}
