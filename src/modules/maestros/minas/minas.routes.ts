import { Router } from 'express';
import { MinasController } from './minas.controller';
import { authenticate, authorize } from '../../../middlewares/auth.middleware';

const router = Router();
const minasController = new MinasController();

router.get('/', authenticate, minasController.getAll.bind(minasController));
router.get('/:id', authenticate, minasController.getById.bind(minasController));

router.post('/', authenticate, authorize('ADMIN', 'LOGISTICA'), minasController.create.bind(minasController));
router.put('/:id', authenticate, authorize('ADMIN', 'LOGISTICA'), minasController.update.bind(minasController));
router.delete('/:id', authenticate, authorize('ADMIN'), minasController.delete.bind(minasController));

export default router;
