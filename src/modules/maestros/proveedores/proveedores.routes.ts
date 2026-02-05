import { Router } from 'express';
import { ProveedoresController } from './proveedores.controller';
import { authenticate, authorize } from '../../../middlewares/auth.middleware';

const router = Router();
const proveedoresController = new ProveedoresController();

router.get('/', authenticate, proveedoresController.getAll.bind(proveedoresController));
router.get('/:id', authenticate, proveedoresController.getById.bind(proveedoresController));

router.post('/', authenticate, authorize('ADMIN', 'LOGISTICA'), proveedoresController.create.bind(proveedoresController));
router.put('/:id', authenticate, authorize('ADMIN', 'LOGISTICA'), proveedoresController.update.bind(proveedoresController));
router.delete('/:id', authenticate, authorize('ADMIN'), proveedoresController.delete.bind(proveedoresController));

export default router;
