import { Router } from 'express';
import { ClasificacionesController } from './clasificaciones.controller';
import { authenticate } from '../../../middlewares/auth.middleware';

const router = Router();
const clasificacionesController = new ClasificacionesController();

router.get('/', authenticate, clasificacionesController.getAll.bind(clasificacionesController));
router.get('/:id', authenticate, clasificacionesController.getById.bind(clasificacionesController));

export default router;
