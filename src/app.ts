import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler } from './middlewares/error.middleware';

// Importar rutas (se agregarán progresivamente)
import authRoutes from './modules/auth/auth.routes';

const app: Application = express();

// Middlewares de seguridad
app.use(helmet());
app.use(
    cors({
        origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
        credentials: true,
    })
);

// Middleware de logging
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
} else {
    app.use(morgan('combined'));
}

// Parseo de JSON y URL-encoded
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (_req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV,
    });
});

// Rutas de API
app.use('/api/auth', authRoutes);

// Ruta 404
app.use((_req, res) => {
    res.status(404).json({
        status: 'error',
        message: 'Ruta no encontrada',
    });
});

// Manejo de errores (debe ser el último middleware)
app.use(errorHandler);

export default app;
