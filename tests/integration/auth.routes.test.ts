import request from 'supertest';
import express from 'express';
import authRoutes from '../../src/modules/auth/auth.routes';
import prisma from '../../src/config/database';

// Mock Prisma for Integration Test (Partial integration, really Controller test)
// For real integration, we would use a test DB.
jest.mock('../../src/config/database', () => ({
    __esModule: true,
    default: {
        usuarios: {
            findUnique: jest.fn(),
            update: jest.fn()
        }
    }
}));

// Mock bcrypt
jest.mock('bcrypt', () => ({
    compare: jest.fn().mockResolvedValue(true),
    hash: jest.fn().mockResolvedValue('hashed_pwd')
}));

const app = express();
app.use(express.json());
app.use('/api/auth', authRoutes);

describe('Auth Routes', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe('POST /api/auth/login', () => {
        beforeAll(() => {
            process.env.JWT_SECRET = 'test_secret';
            process.env.JWT_REFRESH_SECRET = 'test_refresh_secret';
        });

        it('should return tokens on success', async () => {
            (prisma.usuarios.findUnique as jest.Mock).mockResolvedValue({
                id_usuario: 1,
                username: 'admin',
                password_hash: 'hashed_pwd', // Matches mock bcrypt
                activo: true,
                rol: 'ADMIN'
            });

            // Mock update return
            (prisma.usuarios.update as jest.Mock).mockResolvedValue({
                id_usuario: 1,
                ultimo_login: new Date()
            });

            const res = await request(app)
                .post('/api/auth/login')
                .send({ username: 'admin', password: 'password' });

            if (res.status !== 200) {
                console.error('Login Error Response:', res.body);
            }

            expect(res.status).toBe(200);
            expect(res.body.data).toHaveProperty('accessToken');
            expect(res.body.data).toHaveProperty('refreshToken');
        });

        it('should return 401 on invalid user', async () => {
            (prisma.usuarios.findUnique as jest.Mock).mockResolvedValue(null);

            const res = await request(app)
                .post('/api/auth/login')
                .send({ username: 'wrong', password: 'password' });

            expect(res.status).toBe(401);
        });
    });
});
