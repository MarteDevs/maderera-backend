import { z } from 'zod';

export const createMinaSchema = z.object({
    nombre: z.string().min(3).max(100),
    razon_social: z.string().max(150).optional(),
    ruc: z.string().length(11).regex(/^\d+$/).optional().or(z.literal('')),
    ubicacion: z.string().max(150).optional(),
    contacto: z.string().max(100).optional(),
});

export const updateMinaSchema = createMinaSchema.partial();

export const queryMinaSchema = z.object({
    page: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 1)),
    limit: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 20)),
    search: z.string().optional(),
});

export type CreateMinaInput = z.infer<typeof createMinaSchema>;
export type UpdateMinaInput = z.infer<typeof updateMinaSchema>;
export type QueryMinaInput = z.infer<typeof queryMinaSchema>;
