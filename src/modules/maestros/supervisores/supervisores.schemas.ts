import { z } from 'zod';

export const createSupervisorSchema = z.object({
    nombre: z.string().min(3).max(100),
    telefono: z.string().max(20).optional(),
    email: z.string().email().max(120).optional().or(z.literal('')),
});

export const updateSupervisorSchema = createSupervisorSchema.partial();

export const querySupervisorSchema = z.object({
    page: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 1)),
    limit: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 20)),
    search: z.string().optional(),
});

export type CreateSupervisorInput = z.infer<typeof createSupervisorSchema>;
export type UpdateSupervisorInput = z.infer<typeof updateSupervisorSchema>;
export type QuerySupervisorInput = z.infer<typeof querySupervisorSchema>;
