import { Request, Response, NextFunction } from 'express';
import { UsuariosService } from './usuarios.service';
import { registerUserSchema, updateUserSchema, changePasswordSchema } from './usuarios.schemas';

const usuariosService = new UsuariosService();

export class UsuariosController {
    async getAll(req: Request, res: Response, next: NextFunction) {
        try {
            const page = Number(req.query.page) || 1;
            const limit = Number(req.query.limit) || 10;
            const search = req.query.search as string;

            const result = await usuariosService.getAll(page, limit, search);

            res.json({
                status: 'success',
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const result = await usuariosService.getById(Number(id));

            res.json({
                status: 'success',
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    async create(req: Request, res: Response, next: NextFunction) {
        try {
            const validatedData = registerUserSchema.parse(req.body);
            const result = await usuariosService.create(validatedData);

            res.status(201).json({
                status: 'success',
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    async update(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const validatedData = updateUserSchema.parse(req.body);
            const result = await usuariosService.update(Number(id), validatedData);

            res.json({
                status: 'success',
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    async changePassword(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const { password } = changePasswordSchema.parse(req.body);

            await usuariosService.changePassword(Number(id), password);

            res.json({
                status: 'success',
                message: 'Contraseña actualizada correctamente'
            });
        } catch (error) {
            next(error);
        }
    }

    async toggleActive(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const result = await usuariosService.toggleActive(Number(id));

            res.json({
                status: 'success',
                message: `Usuario ${result.activo ? 'activado' : 'desactivado'} correctamente`,
                data: result
            });
        } catch (error) {
            next(error);
        }
    }
}
