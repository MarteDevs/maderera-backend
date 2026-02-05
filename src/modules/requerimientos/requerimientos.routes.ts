import { Router } from 'express';
import { RequerimientosController } from './requerimientos.controller';
import { authenticate } from '../../middlewares/auth.middleware';

const router = Router();
const controller = new RequerimientosController();

router.use(authenticate);

router.post('/', controller.create.bind(controller));
router.get('/', controller.getAll.bind(controller));
router.get('/:id', controller.getById.bind(controller));
router.put('/:id', controller.update.bind(controller));
router.patch('/:id/status', controller.updateStatus.bind(controller));

export default router;
