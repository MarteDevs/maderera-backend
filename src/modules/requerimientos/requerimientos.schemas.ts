import { z } from 'zod';

export const createRequerimientoSchema = z.object({
    id_proveedor: z.number().int().positive('El ID del proveedor es requerido'),
    id_mina: z.number().int().positive('El ID de la mina es requerido'),
    id_supervisor: z.number().int().positive('El ID del supervisor es requerido'),
    observaciones: z.string().optional(),
    fecha_emision: z.string().datetime().optional().or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Formato de fecha inválido (YYYY-MM-DD)')).transform(val => val ? new Date(val) : undefined),
    fecha_prometida: z.string().datetime().optional().or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Formato de fecha inválido (YYYY-MM-DD)')).transform(val => val ? new Date(val) : null),
    detalles: z.array(
        z.object({
            id_producto: z.number().int().positive('El ID del producto es requerido'),
            cantidad_solicitada: z.number().int().positive('La cantidad debe ser mayor a 0'),
            precio_proveedor: z.number().min(0, 'El precio no puede ser negativo'),
            precio_mina: z.number().min(0, 'El precio no puede ser negativo'),
            observacion: z.string().optional(),
        })
    ).min(1, 'Debe incluir al menos un detalle'),
});

export const updateRequerimientoSchema = z.object({
    id_proveedor: z.number().int().positive().optional(),
    id_mina: z.number().int().positive().optional(),
    id_supervisor: z.number().int().positive().optional(),
    observaciones: z.string().optional(),
    fecha_prometida: z.string().transform(val => val ? new Date(val) : undefined).optional(),
    // Nota: La actualización completa de detalles es compleja, por ahora permitimos editar cabecera
    // Si se requiere editar detalles, se suele hacer vía endpoints específicos o reemplazo total
});

export const updateEstadoSchema = z.object({
    estado: z.enum(['PENDIENTE', 'PARCIAL', 'COMPLETADO', 'ANULADO', 'RECHAZADO']),
    motivo_anulacion: z.string().optional(),
}).refine(data => {
    if (data.estado === 'ANULADO' && !data.motivo_anulacion) {
        return false;
    }
    return true;
}, {
    message: "El motivo de anulación es obligatorio al anular",
    path: ["motivo_anulacion"]
});

export const queryRequerimientoSchema = z.object({
    page: z.string().transform((val) => parseInt(val, 10)).default('1'),
    limit: z.string().transform((val) => parseInt(val, 10)).default('10'),
    id_proveedor: z.string().transform((val) => parseInt(val, 10)).optional(),
    estado: z.enum(['PENDIENTE', 'PARCIAL', 'COMPLETADO', 'ANULADO', 'RECHAZADO']).optional(),
    fecha_inicio: z.string().optional(),
    fecha_fin: z.string().optional(),
    search: z.string().optional(), // Para buscar por código
});

export type CreateRequerimientoInput = z.infer<typeof createRequerimientoSchema>;
export type UpdateRequerimientoInput = z.infer<typeof updateRequerimientoSchema>;
export type UpdateEstadoInput = z.infer<typeof updateEstadoSchema>;
