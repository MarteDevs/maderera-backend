import { Router } from 'express';
import { InventarioController } from './inventario.controller';
import { authenticate } from '../../middlewares/auth.middleware';

const router = Router();
const controller = new InventarioController();

router.use(authenticate);

router.get('/', controller.getStock.bind(controller));
router.get('/kardex', controller.getKardex.bind(controller));
router.post('/adjust', controller.adjustStock.bind(controller));

export default router;
