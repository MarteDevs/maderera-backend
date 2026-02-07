import { z } from 'zod';

export const createProductoSchema = z.object({
    nombre: z.string().min(3, 'El nombre debe tener al menos 3 caracteres').max(80),
    id_medida: z.number().int().positive('La medida es requerida'),
    id_clasificacion: z.number().int().positive('La clasificación es inválida').optional(),
    precio_venta_base: z.number().min(0).optional().default(0),
    stock_actual: z.number().int().min(0).optional().default(0),
    observaciones: z.string().max(250).optional(),
    proveedores: z.array(
        z.object({
            id_proveedor: z.number().int().positive(),
            precio_compra_sugerido: z.number().min(0)
        })
    ).optional()
});

export const updateProductoSchema = createProductoSchema.partial();

export const queryProductoSchema = z.object({
    page: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 1)),
    limit: z.string().optional().transform((val) => (val ? parseInt(val, 10) : 20)),
    search: z.string().optional(),
    minStock: z.string().optional().transform((val) => (val ? parseInt(val, 10) : undefined)),
    maxStock: z.string().optional().transform((val) => (val ? parseInt(val, 10) : undefined)),
});

export type CreateProductoInput = z.infer<typeof createProductoSchema>;
export type UpdateProductoInput = z.infer<typeof updateProductoSchema>;
export type QueryProductoInput = z.infer<typeof queryProductoSchema>;
