import 'dotenv/config';
import app from './app';
import prisma from './config/database';

const PORT = process.env.PORT || 3000;

const startServer = async () => {
    try {
        // Verificar que las variables de entorno críticas están configuradas
        if (!process.env.JWT_SECRET || !process.env.JWT_REFRESH_SECRET) {
            throw new Error('Variables JWT_SECRET y JWT_REFRESH_SECRET son requeridas');
        }

        if (!process.env.DATABASE_URL) {
            throw new Error('Variable DATABASE_URL es requerida');
        }

        // Verificar conexión a base de datos
        await prisma.$queryRaw`SELECT 1`;
        console.info('✅ Conexión a base de datos verificada');

        // Iniciar servidor
        app.listen(PORT, () => {
            console.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            console.info(`🚀 Servidor corriendo en http://localhost:${PORT}`);
            console.info(`🏥 Health check: http://localhost:${PORT}/health`);
            console.info(`🌍 Entorno: ${process.env.NODE_ENV || 'development'}`);
            console.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        });
    } catch (error) {
        console.error('❌ Error al iniciar servidor:', error);
        await prisma.$disconnect();
        process.exit(1);
    }
};

// Manejo de cierre graceful
const gracefulShutdown = async () => {
    console.info('\n👋 Cerrando servidor...');
    await prisma.$disconnect();
    process.exit(0);
};

process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

// Iniciar servidor
startServer();
