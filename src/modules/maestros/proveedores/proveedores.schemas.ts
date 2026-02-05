import { z } from 'zod';

export const createProveedorSchema = z.object({
    nombre: z.string().min(3, 'El nombre debe tener al menos 3 caracteres').max(120),
    razon_social: z.string().max(150).optional(),
    ruc: z.string().length(11, 'El RUC debe tener 11 dígitos').regex(/^\d+$/, 'El RUC debe contener solo números').optional().or(z.literal('')),
    contacto: z.string().max(100).optional(),
    telefono: z.string().max(20).optional(),
});

export const updateProveedorSchema = createProveedorSchema.partial();

export const queryProveedorSchema = z.object({
    page: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 1)),
    limit: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 20)),
    search: z.string().optional(),
});

export type CreateProveedorInput = z.infer<typeof createProveedorSchema>;
export type UpdateProveedorInput = z.infer<typeof updateProveedorSchema>;
export type QueryProveedorInput = z.infer<typeof queryProveedorSchema>;
