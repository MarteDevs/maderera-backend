import { Router } from 'express';
import { UsuariosController } from './usuarios.controller';
import { authenticate, authorize } from '../../middlewares/auth.middleware';

const router = Router();
const usuariosController = new UsuariosController();

// Todas las rutas requieren autenticación y rol ADMIN
router.use(authenticate);
router.use(authorize('ADMIN'));

router.get('/', usuariosController.getAll.bind(usuariosController));
router.get('/:id', usuariosController.getById.bind(usuariosController));
router.post('/', usuariosController.create.bind(usuariosController));
router.put('/:id', usuariosController.update.bind(usuariosController));
router.patch('/:id/password', usuariosController.changePassword.bind(usuariosController));
router.patch('/:id/toggle-active', usuariosController.toggleActive.bind(usuariosController));

export const usuariosRoutes = router;
