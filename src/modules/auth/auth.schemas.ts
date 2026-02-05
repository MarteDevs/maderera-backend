import { z } from 'zod';

export const loginSchema = z.object({
    username: z.string().min(3, 'El usuario debe tener al menos 3 caracteres'),
    password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres'),
});

export const refreshTokenSchema = z.object({
    refreshToken: z.string().min(1, 'Refresh token es requerido'),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
