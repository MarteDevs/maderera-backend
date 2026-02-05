import { Request, Response, NextFunction } from 'express';
import { AppError } from './error.middleware';
import { verifyAccessToken } from '../utils/jwt.util';

export interface AuthRequest extends Request {
    user?: {
        id_usuario: number;
        username: string;
        rol: string;
    };
}

export const authenticate = (req: AuthRequest, _res: Response, next: NextFunction) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new AppError(401, 'Token de autenticación requerido');
        }

        const token = authHeader.substring(7);
        const payload = verifyAccessToken(token);

        req.user = payload;
        next();
    } catch (error) {
        if (error instanceof Error && error.name === 'TokenExpiredError') {
            next(new AppError(401, 'Token expirado'));
        } else if (error instanceof Error && error.name === 'JsonWebTokenError') {
            next(new AppError(401, 'Token inválido'));
        } else {
            next(error);
        }
    }
};

export const authorize = (...roles: string[]) => {
    return (req: AuthRequest, _res: Response, next: NextFunction) => {
        if (!req.user) {
            return next(new AppError(401, 'No autenticado'));
        }

        if (!roles.includes(req.user.rol)) {
            return next(new AppError(403, 'No tienes permisos para realizar esta acción'));
        }

        next();
    };
};
