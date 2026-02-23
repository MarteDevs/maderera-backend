import { z } from 'zod';

// Detalle de un item del requerimiento (cantidad recibida)
const detalleRequerimientoSchema = z.object({
    es_extra: z.literal(false).default(false),
    id_detalle_requerimiento: z.number().int().positive(),
    cantidad_recibida: z.number().int().positive('La cantidad recibida debe ser mayor a 0'),
    estado_entrega: z.enum(['OK', 'RECHAZADO', 'PARCIAL', 'MUESTRA', 'DA_ADO']).default('OK'),
    observacion: z.string().optional(),
});

// Detalle de un item EXTRA (no solicitado en el requerimiento)
const detalleExtraSchema = z.object({
    es_extra: z.literal(true),
    id_producto: z.number().int().positive('Debe seleccionar un producto'),
    id_medida: z.number().int().positive('Debe seleccionar una medida'),
    cantidad_recibida: z.number().int().positive('La cantidad recibida debe ser mayor a 0'),
    estado_entrega: z.enum(['OK', 'RECHAZADO', 'PARCIAL', 'MUESTRA', 'DA_ADO']).default('OK'),
    observacion: z.string().optional(),
});

export const viajeDetalleSchema = z.discriminatedUnion('es_extra', [
    detalleRequerimientoSchema,
    detalleExtraSchema,
]);

export const createViajeSchema = z.object({
    id_requerimiento: z.number().int().positive('El ID del requerimiento es requerido'),
    placa_vehiculo: z.string().min(1, 'La placa del vehículo es requerida').max(20),
    conductor: z.string().min(1, 'El nombre del conductor es requerido').max(100),
    numero_vale: z.string().max(50, 'El número de vale no puede exceder 50 caracteres').optional(),
    etiqueta_viaje: z.string().max(50, 'La etiqueta de viaje no puede exceder 50 caracteres').optional(),
    fecha_ingreso: z.string().datetime().optional().transform(val => val ? new Date(val) : new Date()),
    observaciones: z.string().optional(),
    detalles: z.array(viajeDetalleSchema).min(1, 'Debe registrar al menos un detalle en el viaje'),
});

export const queryViajeSchema = z.object({
    page: z.string().transform((val) => parseInt(val, 10)).default('1'),
    limit: z.string().transform((val) => parseInt(val, 10)).default('10'),
    id_requerimiento: z.string().transform((val) => parseInt(val, 10)).optional(),
    id_proveedor: z.string().transform((val) => parseInt(val, 10)).optional(),
    id_mina: z.string().transform((val) => parseInt(val, 10)).optional(),
    numero_vale: z.string().optional(),
    search: z.string().optional(),
    fecha_inicio: z.string().optional(),
    fecha_fin: z.string().optional(),
    mes: z.string().transform((val) => parseInt(val, 10)).optional(),
    anio: z.string().transform((val) => parseInt(val, 10)).optional(),
    etiqueta_viaje: z.string().optional(),
});

export type CreateViajeInput = z.infer<typeof createViajeSchema>;
export type QueryViajeInput = z.infer<typeof queryViajeSchema>;
export type ViajeDetalle = z.infer<typeof viajeDetalleSchema>;
