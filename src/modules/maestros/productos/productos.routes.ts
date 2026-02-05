import { Router } from 'express';
import { ProductosController } from './productos.controller';
import { authenticate, authorize } from '../../../middlewares/auth.middleware';

const router = Router();
const productosController = new ProductosController();

// Rutas públicas (o protegidas según requerimiento, aquí protegidas básicas)
router.get('/', authenticate, productosController.getAll.bind(productosController));
router.get('/:id', authenticate, productosController.getById.bind(productosController));

// Rutas de administración
router.post('/', authenticate, authorize('ADMIN', 'LOGISTICA'), productosController.create.bind(productosController));
router.put('/:id', authenticate, authorize('ADMIN', 'LOGISTICA'), productosController.update.bind(productosController));
router.delete('/:id', authenticate, authorize('ADMIN'), productosController.delete.bind(productosController));

export default router;
