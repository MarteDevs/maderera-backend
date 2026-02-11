
import { Router } from 'express';
import { reportesController } from './reportes.controller';
import { authenticate } from '../../middlewares/auth.middleware';

const router = Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

router.get('/kpis', reportesController.getKpis.bind(reportesController));
router.get('/top-minas', reportesController.getTopMinas.bind(reportesController));
router.get('/tendencia', reportesController.getTendencia.bind(reportesController));

export default router;
