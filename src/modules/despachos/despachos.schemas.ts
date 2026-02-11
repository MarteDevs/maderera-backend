import { z } from 'zod';

// Enum para estados de despacho
export const DespachoEstadoEnum = z.enum(['PREPARANDO', 'EN_TRANSITO', 'ENTREGADO', 'ANULADO']);

// Schema para el detalle de un despacho
export const despachoDetalleSchema = z.object({
    id_producto: z.number().int().positive(),
    id_medida: z.number().int().positive(),
    cantidad_despachada: z.number().int().positive(),
    observacion: z.string().max(250).optional()
});

// Schema para crear un despacho
export const createDespachoSchema = z.object({
    id_mina: z.number().int().positive(),
    id_supervisor: z.number().int().positive().optional(),
    id_viaje: z.number().int().positive().optional(),
    observaciones: z.string().optional(),
    detalles: z.array(despachoDetalleSchema).min(1, 'Debe incluir al menos un producto')
});

// Schema para actualizar un despacho (solo en estado PREPARANDO)
export const updateDespachoSchema = z.object({
    id_mina: z.number().int().positive().optional(),
    id_supervisor: z.number().int().positive().optional(),
    id_viaje: z.number().int().positive().optional(),
    observaciones: z.string().optional(),
    detalles: z.array(despachoDetalleSchema).min(1).optional()
});

// Schema para cambiar a EN_TRANSITO
export const transitoDespachoSchema = z.object({
    fecha_salida: z.string().datetime().optional()
});

// Schema para marcar ENTREGADO
export const entregarDespachoSchema = z.object({
    fecha_entrega: z.string().datetime().optional()
});

// Schema para anular
export const anularDespachoSchema = z.object({
    motivo_anulacion: z.string().min(10, 'El motivo debe tener al menos 10 caracteres')
});

// Schema para filtros de listado
export const queryDespachosSchema = z.object({
    page: z.string().optional().default('1').transform(Number),
    limit: z.string().optional().default('10').transform(Number),
    estado: DespachoEstadoEnum.optional(),
    id_mina: z.string().optional().transform(val => val ? Number(val) : undefined),
    id_viaje: z.string().optional().transform(val => val ? Number(val) : undefined),
    id_requerimiento: z.string().optional().transform(val => val ? Number(val) : undefined),
    // Acepta formato de fecha simple (yyyy-mm-dd) en lugar de datetime
    fecha_desde: z.string().optional().transform(val => val || undefined),
    fecha_hasta: z.string().optional().transform(val => val || undefined),
    search: z.string().optional()
});

// Types exports
export type CreateDespachoInput = z.infer<typeof createDespachoSchema>;
export type UpdateDespachoInput = z.infer<typeof updateDespachoSchema>;
export type TransitoDespachoInput = z.infer<typeof transitoDespachoSchema>;
export type EntregarDespachoInput = z.infer<typeof entregarDespachoSchema>;
export type AnularDespachoInput = z.infer<typeof anularDespachoSchema>;
export type QueryDespachosInput = z.infer<typeof queryDespachosSchema>;
export type DespachoDetalle = z.infer<typeof despachoDetalleSchema>;
