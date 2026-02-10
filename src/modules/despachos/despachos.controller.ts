import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { despachosService } from './despachos.service';
import {
    createDespachoSchema,
    updateDespachoSchema,
    queryDespachosSchema,
    transitoDespachoSchema,
    entregarDespachoSchema,
    anularDespachoSchema
} from './despachos.schemas';

export class DespachosController {
    /**
     * GET /despachos - Listar despachos con filtros
     */
    async list(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const query = queryDespachosSchema.parse(req.query);
            const result = await despachosService.list(query);
            res.json(result);
        } catch (error) {
            next(error);
        }
    }

    /**
     * GET /despachos/:id - Obtener despacho por ID
     */
    async getById(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const despacho = await despachosService.getById(id);
            res.json(despacho);
        } catch (error) {
            next(error);
        }
    }

    /**
     * POST /despachos - Crear nuevo despacho
     */
    async create(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const data = createDespachoSchema.parse(req.body);
            const usuario = req.user?.username || 'sistema';
            const despacho = await despachosService.create(data, usuario);
            res.status(201).json(despacho);
        } catch (error) {
            next(error);
        }
    }

    /**
     * PUT /despachos/:id - Actualizar despacho (solo PREPARANDO)
     */
    async update(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = updateDespachoSchema.parse(req.body);
            const usuario = req.user?.username || 'sistema';
            const despacho = await despachosService.update(id, data, usuario);
            res.json(despacho);
        } catch (error) {
            next(error);
        }
    }

    /**
     * DELETE /despachos/:id - Eliminar despacho (solo PREPARANDO)
     */
    async delete(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const result = await despachosService.delete(id);
            res.json(result);
        } catch (error) {
            next(error);
        }
    }

    /**
     * PATCH /despachos/:id/transito - Cambiar a EN_TRANSITO
     */
    async cambiarATransito(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = transitoDespachoSchema.parse(req.body);
            const usuario = req.user?.username || 'sistema';
            const despacho = await despachosService.cambiarATransito(id, usuario, data.fecha_salida);
            res.json(despacho);
        } catch (error) {
            next(error);
        }
    }

    /**
     * PATCH /despachos/:id/entregar - Marcar como ENTREGADO
     */
    async marcarEntregado(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = entregarDespachoSchema.parse(req.body);
            const usuario = req.user?.username || 'sistema';
            const despacho = await despachosService.marcarEntregado(id, usuario, data.fecha_entrega);
            res.json(despacho);
        } catch (error) {
            next(error);
        }
    }

    /**
     * PATCH /despachos/:id/anular - Anular despacho
     */
    async anular(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const id = parseInt(req.params.id);
            const data = anularDespachoSchema.parse(req.body);
            const usuario = req.user?.username || 'sistema';
            const despacho = await despachosService.anular(id, data, usuario);
            res.json(despacho);
        } catch (error) {
            next(error);
        }
    }
}

export const despachosController = new DespachosController();
