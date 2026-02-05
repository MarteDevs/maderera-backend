import { Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service';
import { loginSchema, refreshTokenSchema } from './auth.schemas';
import { AuthRequest } from '../../middlewares/auth.middleware';

const authService = new AuthService();

export class AuthController {
    async login(req: Request, res: Response, next: NextFunction) {
        try {
            const validatedData = loginSchema.parse(req.body);
            const result = await authService.login(validatedData.username, validatedData.password);

            res.json({
                status: 'success',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async refresh(req: Request, res: Response, next: NextFunction) {
        try {
            const validatedData = refreshTokenSchema.parse(req.body);
            const result = await authService.refreshAccessToken(validatedData.refreshToken);

            res.json({
                status: 'success',
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }

    async getMe(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            if (!req.user) {
                throw new Error('Usuario no autenticado');
            }

            const user = await authService.getMe(req.user.id_usuario);

            res.json({
                status: 'success',
                data: user,
            });
        } catch (error) {
            next(error);
        }
    }

    async logout(req: Request, res: Response) {
        // En una implementación completa, aquí se invalidaría el token en Redis
        res.json({
            status: 'success',
            message: 'Sesión cerrada exitosamente',
        });
    }
}
