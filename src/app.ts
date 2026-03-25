import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler } from './middlewares/error.middleware';

// Importar rutas (se agregarán progresivamente)
import authRoutes from './modules/auth/auth.routes';
import productosRoutes from './modules/maestros/productos/productos.routes';
import proveedoresRoutes from './modules/maestros/proveedores/proveedores.routes';
import minasRoutes from './modules/maestros/minas/minas.routes';
import supervisoresRoutes from './modules/maestros/supervisores/supervisores.routes';
import preciosRoutes from './modules/maestros/precios/precios.routes';
import medidasRoutes from './modules/maestros/medidas/medidas.routes';
import clasificacionesRoutes from './modules/maestros/clasificaciones/clasificaciones.routes';
import requerimientosRoutes from './modules/requerimientos/requerimientos.routes';
import viajesRoutes from './modules/viajes/viajes.routes';
import despachosRoutes from './modules/despachos/despachos.routes';
import inventarioRoutes from './modules/inventario/inventario.routes';
import { usuariosRoutes } from './modules/usuarios/usuarios.routes';
import reportesRoutes from './modules/reportes/reportes.routes';
import swaggerUi from 'swagger-ui-express';
import swaggerDocument from './config/swagger';

const app: Application = express();

// Middlewares de seguridad
app.use(helmet());
// Configuración de orígenes permitidos (separados por coma en el .env)
const allowedOrigins = process.env.CORS_ORIGIN 
    ? process.env.CORS_ORIGIN.split(',') 
    : ['http://localhost:5173', 'http://localhost:8080'];

app.use(
    cors({
        origin: function (origin, callback) {
            // Permitir peticiones sin origen (como las apps nativas de iOS/Android o Postman)
            if (!origin) return callback(null, true);
            
            // Permitir comodín si está configurado así en el .env
            if (process.env.CORS_ORIGIN === '*') return callback(null, true);

            // Validar si el origen está en la lista permitida
            if (allowedOrigins.indexOf(origin) !== -1) {
                return callback(null, true);
            } else {
                return callback(new Error('Bloqueado por CORS: El origen no está permitido.'), false);
            }
        },
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
app.use('/api/users', usuariosRoutes);
app.use('/api/products/medidas', medidasRoutes);
app.use('/api/products/clasificaciones', clasificacionesRoutes);
app.use('/api/products', productosRoutes);
app.use('/api/providers', proveedoresRoutes);
app.use('/api/mines', minasRoutes);
app.use('/api/supervisors', supervisoresRoutes);
app.use('/api/prices', preciosRoutes);
app.use('/api/requirements', requerimientosRoutes);
app.use('/api/viajes', viajesRoutes);
app.use('/api/despachos', despachosRoutes);
app.use('/api/inventory', inventarioRoutes);
app.use('/api/reportes', reportesRoutes);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

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
