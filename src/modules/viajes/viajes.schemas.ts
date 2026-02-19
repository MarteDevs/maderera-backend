import { z } from 'zod';

export const createViajeSchema = z.object({
    id_requerimiento: z.number().int().positive('El ID del requerimiento es requerido'),
    placa_vehiculo: z.string().min(1, 'La placa del vehículo es requerida').max(20),
    conductor: z.string().min(1, 'El nombre del conductor es requerido').max(100),
    numero_vale: z.string().max(50, 'El número de vale no puede exceder 50 caracteres').optional(),
    etiqueta_viaje: z.string().max(50, 'La etiqueta de viaje no puede exceder 50 caracteres').optional(),
    fecha_ingreso: z.string().datetime().optional().transform(val => val ? new Date(val) : new Date()),
    observaciones: z.string().optional(),
    detalles: z.array(
        z.object({
            id_detalle_requerimiento: z.number().int().positive(),
            cantidad_recibida: z.number().int().positive('La cantidad recibida debe ser mayor a 0'),
            estado_entrega: z.enum(['OK', 'RECHAZADO', 'PARCIAL', 'MUESTRA', 'DA_ADO']).default('OK'),
            observacion: z.string().optional(),
        })
    ).min(1, 'Debe registrar al menos un detalle en el viaje'),
});

export const queryViajeSchema = z.object({
    page: z.string().transform((val) => parseInt(val, 10)).default('1'),
    limit: z.string().transform((val) => parseInt(val, 10)).default('10'),
    id_requerimiento: z.string().transform((val) => parseInt(val, 10)).optional(),
    id_proveedor: z.string().transform((val) => parseInt(val, 10)).optional(), // New
    id_mina: z.string().transform((val) => parseInt(val, 10)).optional(), // New
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
