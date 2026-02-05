import { z } from 'zod';

export const queryStockSchema = z.object({
    page: z.string().transform((val) => parseInt(val, 10)).default('1'),
    limit: z.string().transform((val) => parseInt(val, 10)).default('20'),
    search: z.string().optional(),
    id_clasificacion: z.string().transform((val) => parseInt(val, 10)).optional(),
    id_medida: z.string().transform((val) => parseInt(val, 10)).optional(),
    bajo_stock: z.string().transform((val) => val === 'true').optional(),
});

export const queryKardexSchema = z.object({
    id_producto: z.string().transform((val) => parseInt(val, 10)).optional(),
    fecha_inicio: z.string().optional(),
    fecha_fin: z.string().optional(),
    limit: z.string().transform((val) => parseInt(val, 10)).default('50'),
    tipo_movimiento: z.enum(['ENTRADA', 'SALIDA', 'AJUSTE_POS', 'AJUSTE_NEG', 'DEVOLUCION', 'AJUSTE_MANUAL']).optional(),
});

export const adjustStockSchema = z.object({
    id_producto: z.number().int().positive('ID de producto requerido'),
    cantidad: z.number().int().refine((val) => val !== 0, 'La cantidad no puede ser 0'),
    tipo_movimiento: z.enum(['ENTRADA', 'SALIDA', 'AJUSTE_MANUAL']),
    observaciones: z.string().min(5, 'Debe especificar un motivo para el ajuste (min 5 caracteres)'),
});

export type QueryStockInput = z.infer<typeof queryStockSchema>;
export type QueryKardexInput = z.infer<typeof queryKardexSchema>;
export type AdjustStockInput = z.infer<typeof adjustStockSchema>;
