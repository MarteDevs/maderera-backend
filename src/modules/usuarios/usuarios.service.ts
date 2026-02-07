import bcrypt from 'bcrypt';
import prisma from '../../config/database';
import { AppError } from '../../middlewares/error.middleware';
// import { PaginatedResponse } from '../../types';

export class UsuariosService {
    async getAll(page: number = 1, limit: number = 10, search?: string) {
        const skip = (page - 1) * limit;

        const where: any = {};

        if (search) {
            where.OR = [
                { username: { contains: search } },
                { nombre_completo: { contains: search } }
            ];
        }

        const [users, total] = await Promise.all([
            prisma.usuarios.findMany({
                where,
                skip,
                take: limit,
                select: {
                    id_usuario: true,
                    username: true,
                    nombre_completo: true,
                    rol: true,
                    activo: true,
                    ultimo_login: true,
                    id_supervisor: true,
                    supervisores: {
                        select: {
                            nombre: true
                        }
                    }
                },
                orderBy: { created_at: 'desc' }
            }),
            prisma.usuarios.count({ where })
        ]);

        return {
            data: users,
            pagination: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit)
            }
        };
    }

    async getById(id: number) {
        const user = await prisma.usuarios.findUnique({
            where: { id_usuario: id },
            select: {
                id_usuario: true,
                username: true,
                nombre_completo: true,
                rol: true,
                activo: true,
                id_supervisor: true
            }
        });

        if (!user) {
            throw new AppError(404, 'Usuario no encontrado');
        }

        return user;
    }

    async create(data: any) {
        // Verificar si el username ya existe
        const existingUser = await prisma.usuarios.findUnique({
            where: { username: data.username }
        });

        if (existingUser) {
            throw new AppError(400, 'El nombre de usuario ya está en uso');
        }

        const passwordHash = await bcrypt.hash(data.password, 10);

        return await prisma.usuarios.create({
            data: {
                username: data.username,
                password_hash: passwordHash,
                nombre_completo: data.nombre_completo,
                rol: data.rol,
                id_supervisor: data.id_supervisor,
                activo: true
            },
            select: {
                id_usuario: true,
                username: true,
                nombre_completo: true,
                rol: true
            }
        });
    }

    async update(id: number, data: any) {
        const user = await prisma.usuarios.findUnique({ where: { id_usuario: id } });
        if (!user) throw new AppError(404, 'Usuario no encontrado');

        return await prisma.usuarios.update({
            where: { id_usuario: id },
            data: {
                nombre_completo: data.nombre_completo,
                rol: data.rol,
                activo: data.activo,
                id_supervisor: data.id_supervisor
            },
            select: {
                id_usuario: true,
                nombre_completo: true,
                rol: true,
                activo: true,
                id_supervisor: true
            }
        });
    }

    async changePassword(id: number, password: string) {
        const user = await prisma.usuarios.findUnique({ where: { id_usuario: id } });
        if (!user) throw new AppError(404, 'Usuario no encontrado');

        const passwordHash = await bcrypt.hash(password, 10);

        await prisma.password_history.create({
            data: {
                id_usuario: id,
                password_hash: user.password_hash // Save OLD password
            }
        });

        await prisma.usuarios.update({
            where: { id_usuario: id },
            data: { password_hash: passwordHash }
        });
    }

    async toggleActive(id: number) {
        const user = await prisma.usuarios.findUnique({ where: { id_usuario: id } });
        if (!user) throw new AppError(404, 'Usuario no encontrado');

        return await prisma.usuarios.update({
            where: { id_usuario: id },
            data: { activo: !user.activo },
            select: { id_usuario: true, activo: true }
        });
    }
}
