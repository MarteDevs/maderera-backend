import { z } from 'zod';

export const createPrecioSchema = z.object({
    id_proveedor: z.number().int().positive(),
    id_producto: z.number().int().positive(),
    precio_compra_sugerido: z.number().min(0),
    activo: z.boolean().optional().default(true),
});

export const updatePrecioSchema = createPrecioSchema.partial();

export const queryPrecioSchema = z.object({
    page: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 1)),
    limit: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 20)),
    id_proveedor: z.string().optional().transform((val) => (val ? parseInt(val, 10) : undefined)),
    id_producto: z.string().optional().transform((val) => (val ? parseInt(val, 10) : undefined)),
    activo: z.string().optional().transform((val) => (val === 'true')),
});

export type CreatePrecioInput = z.infer<typeof createPrecioSchema>;
export type UpdatePrecioInput = z.infer<typeof updatePrecioSchema>;
export type QueryPrecioInput = z.infer<typeof queryPrecioSchema>;
