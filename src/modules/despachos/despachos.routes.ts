import { Router } from 'express';
import { despachosController } from './despachos.controller';
import { authenticate } from '../../middlewares/auth.middleware';

const router = Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

// Listado y detalle
router.get('/', despachosController.list.bind(despachosController));
router.get('/:id', despachosController.getById.bind(despachosController));

// CRUD básico
router.post('/', despachosController.create.bind(despachosController));
router.put('/:id', despachosController.update.bind(despachosController));
router.delete('/:id', despachosController.delete.bind(despachosController));

// Cambios de estado
router.patch('/:id/transito', despachosController.cambiarATransito.bind(despachosController));
router.patch('/:id/entregar', despachosController.marcarEntregado.bind(despachosController));
router.patch('/:id/anular', despachosController.anular.bind(despachosController));

export default router;
