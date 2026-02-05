import bcrypt from 'bcrypt';
import prisma from '../../config/database';
import { AppError } from '../../middlewares/error.middleware';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from '../../utils/jwt.util';

export class AuthService {
    async login(username: string, password: string) {
        // Buscar usuario
        const usuario = await prisma.usuarios.findUnique({
            where: { username },
            include: {
                supervisores: true,
            },
        });

        if (!usuario) {
            throw new AppError(401, 'Credenciales inválidas');
        }

        if (!usuario.activo) {
            throw new AppError(401, 'Usuario inactivo. Contacte al administrador');
        }

        // Verificar contraseña
        const isValidPassword = await bcrypt.compare(password, usuario.password_hash);
        if (!isValidPassword) {
            // Incrementar intentos fallidos
            await prisma.usuarios.update({
                where: { id_usuario: usuario.id_usuario },
                data: {
                    intentos_fallidos: { increment: 1 },
                },
            });

            throw new AppError(401, 'Credenciales inválidas');
        }

        // Resetear intentos fallidos y actualizar último login
        await prisma.usuarios.update({
            where: { id_usuario: usuario.id_usuario },
            data: {
                intentos_fallidos: 0,
                ultimo_login: new Date(),
            },
        });

        // Generar tokens
        const payload = {
            id_usuario: usuario.id_usuario,
            username: usuario.username,
            rol: usuario.rol as string,
        };

        const accessToken = generateAccessToken(payload);
        const refreshToken = generateRefreshToken(payload);

        return {
            accessToken,
            refreshToken,
            user: {
                id: usuario.id_usuario,
                username: usuario.username,
                nombre: usuario.nombre_completo,
                rol: usuario.rol,
            },
        };
    }

    async refreshAccessToken(refreshToken: string) {
        try {
            const payload = verifyRefreshToken(refreshToken);

            // Verificar que el usuario sigue existiendo y activo
            const usuario = await prisma.usuarios.findUnique({
                where: { id_usuario: payload.id_usuario },
            });

            if (!usuario || !usuario.activo) {
                throw new AppError(401, 'Usuario no válido');
            }

            // Generar nuevo access token
            const newPayload = {
                id_usuario: usuario.id_usuario,
                username: usuario.username,
                rol: usuario.rol as string,
            };

            const accessToken = generateAccessToken(newPayload);

            return { accessToken };
        } catch (error) {
            throw new AppError(401, 'Refresh token inválido o expirado');
        }
    }

    async getMe(userId: number) {
        const usuario = await prisma.usuarios.findUnique({
            where: { id_usuario: userId },
            select: {
                id_usuario: true,
                username: true,
                nombre_completo: true,
                rol: true,
                activo: true,
                ultimo_login: true,
                created_at: true,
                supervisores: {
                    select: {
                        id_supervisor: true,
                        nombre: true,
                        telefono: true,
                        email: true,
                    },
                },
            },
        });

        if (!usuario) {
            throw new AppError(404, 'Usuario no encontrado');
        }

        return usuario;
    }
}
