import { Router } from 'express';
import { SupervisoresController } from './supervisores.controller';
import { authenticate, authorize } from '../../../middlewares/auth.middleware';

const router = Router();
const supervisoresController = new SupervisoresController();

router.get('/', authenticate, supervisoresController.getAll.bind(supervisoresController));
router.get('/:id', authenticate, supervisoresController.getById.bind(supervisoresController));

router.post('/', authenticate, authorize('ADMIN', 'LOGISTICA'), supervisoresController.create.bind(supervisoresController));
router.put('/:id', authenticate, authorize('ADMIN', 'LOGISTICA'), supervisoresController.update.bind(supervisoresController));
router.delete('/:id', authenticate, authorize('ADMIN'), supervisoresController.delete.bind(supervisoresController));

export default router;
