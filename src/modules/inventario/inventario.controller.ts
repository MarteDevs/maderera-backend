import { Request, Response, NextFunction } from 'express';
import { InventarioService } from './inventario.service';
import { queryStockSchema, queryKardexSchema, adjustStockSchema } from './inventario.schemas';
import { AuthRequest } from '../../middlewares/auth.middleware';

const inventarioService = new InventarioService();

export class InventarioController {
    async getStock(req: Request, res: Response, next: NextFunction) {
        try {
            const query = queryStockSchema.parse(req.query);
            const result = await inventarioService.getStock(query);
            res.json({ status: 'success', data: result });
        } catch (error) {
            next(error);
        }
    }

    async getKardex(req: Request, res: Response, next: NextFunction) {
        try {
            const query = queryKardexSchema.parse(req.query);
            const result = await inventarioService.getKardex(query);
            res.json({ status: 'success', data: result });
        } catch (error) {
            next(error);
        }
    }

    async adjustStock(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const data = adjustStockSchema.parse(req.body);
            // Solo ADMIN o LOGISTICA deberían poder hacer esto.
            // Por ahora validamos autenticación, RBAC puede ser middleware.
            const result = await inventarioService.adjustStock(data, req.user?.id_usuario, req.user?.username);
            res.json({ status: 'success', message: 'Ajuste de inventario registrado', data: result });
        } catch (error) {
            next(error);
        }
    }
}
