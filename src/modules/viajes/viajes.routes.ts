import { Router } from 'express';
import { ViajesController } from './viajes.controller';
import { authenticate } from '../../middlewares/auth.middleware';

const router = Router();
const controller = new ViajesController();

router.use(authenticate);

router.post('/', controller.create.bind(controller));
router.get('/:id', controller.getById.bind(controller));
router.get('/requerimiento/:id_requerimiento', controller.getByRequerimiento.bind(controller));

// Opcional: Ruta para listar viajes con filtros si fuera necesario en el futuro
router.get('/', controller.getAll.bind(controller));

export default router;
