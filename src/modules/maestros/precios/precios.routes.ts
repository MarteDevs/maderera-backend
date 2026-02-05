import { Router } from 'express';
import { PreciosController } from './precios.controller';
import { authenticate, authorize } from '../../../middlewares/auth.middleware';

const router = Router();
const preciosController = new PreciosController();

router.get('/', authenticate, preciosController.getAll.bind(preciosController));
router.get('/:id', authenticate, preciosController.getById.bind(preciosController));

// Solo Admin y Logística pueden gestionar precios
router.post('/', authenticate, authorize('ADMIN', 'LOGISTICA'), preciosController.create.bind(preciosController));
router.put('/:id', authenticate, authorize('ADMIN', 'LOGISTICA'), preciosController.update.bind(preciosController));
router.delete('/:id', authenticate, authorize('ADMIN', 'LOGISTICA'), preciosController.delete.bind(preciosController));

export default router;
