import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  errorFormat: 'pretty',
});

// Conexión inicial
prisma.$connect()
  .then(() => {
    console.info('✅ Prisma conectado a la base de datos');
  })
  .catch((error) => {
    console.error('❌ Error al conectar Prisma:', error);
    process.exit(1);
  });

// Manejo de cierre graceful
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

export default prisma;
