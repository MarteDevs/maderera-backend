import { Router } from 'express';
import { MedidasController } from './medidas.controller';
import { authenticate } from '../../../middlewares/auth.middleware';

const router = Router();
const medidasController = new MedidasController();

router.get('/', authenticate, medidasController.getAll.bind(medidasController));
router.get('/:id', authenticate, medidasController.getById.bind(medidasController));

export default router;
