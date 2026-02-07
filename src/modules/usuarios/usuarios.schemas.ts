import { z } from 'zod';

export const registerUserSchema = z.object({
    username: z.string().min(3, 'El nombre de usuario debe tener al menos 3 caracteres'),
    password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres'),
    nombre_completo: z.string().min(3, 'El nombre completo es requerido'),
    rol: z.enum(['ADMIN', 'LOGISTICA', 'SUPERVISOR', 'MINA']),
    id_supervisor: z.number().optional(),
});

export const updateUserSchema = z.object({
    nombre_completo: z.string().min(3, 'El nombre completo es requerido').optional(),
    rol: z.enum(['ADMIN', 'LOGISTICA', 'SUPERVISOR', 'MINA']).optional(),
    activo: z.boolean().optional(),
    id_supervisor: z.number().optional().nullable(),
});

export const changePasswordSchema = z.object({
    password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres'),
});
