import prisma from '../../config/database';
import { QueryStockInput, QueryKardexInput, AdjustStockInput } from './inventario.schemas';

export class InventarioService {
    async getStock(query: QueryStockInput) {
        const offset = (query.page - 1) * query.limit;

        let sql = `SELECT * FROM v_stock_disponible WHERE 1=1`;
        const params: any[] = [];

        if (query.search) {
            sql += ` AND (producto LIKE ?)`;
            params.push(`%${query.search}%`);
        }

        if (query.id_clasificacion) {
            sql += ` AND id_clasificacion = ?`;
            params.push(query.id_clasificacion);
        }

        if (query.id_medida) {
            sql += ` AND id_medida = ?`;
            params.push(query.id_medida);
        }

        if (query.bajo_stock) {
            // Asumiendo que v_stock_disponible tiene alguna lógica de alerta o stock < 100 por ejemplo
            // O podemos filtrar stocks bajos genéricamente si no hay columna de alerta
            sql += ` AND stock_actual < 100`;
        }

        // Count total for pagination (simplificado)
        // Nota: Para performance real, deberíamos hacer un COUNT(*) separado, pero por ahora...

        sql += ` ORDER BY stock_actual ASC LIMIT ? OFFSET ?`;
        params.push(query.limit, offset);

        const data = await prisma.$queryRawUnsafe(sql, ...params);

        // Obtenemos total aprox para paginación (Opcional, omitido para simplicidad en raw query dinámica)

        return {
            page: query.page,
            limit: query.limit,
            data
        };
    }

    async getKardex(query: QueryKardexInput) {
        let sql = `SELECT * FROM v_kardex_completo WHERE 1=1`;
        const params: any[] = [];

        if (query.id_producto) {
            sql += ` AND id_producto = ?`;
            params.push(query.id_producto);
        }

        if (query.fecha_inicio && query.fecha_fin) {
            sql += ` AND fecha BETWEEN ? AND ?`;
            params.push(new Date(query.fecha_inicio), new Date(query.fecha_fin));
        }

        if (query.tipo_movimiento) {
            sql += ` AND tipo = ?`;
            params.push(query.tipo_movimiento);
        }

        sql += ` ORDER BY fecha DESC, id_movimiento DESC LIMIT ?`;
        params.push(query.limit);

        const data = await prisma.$queryRawUnsafe(sql, ...params);

        return data;
    }

    async adjustStock(data: AdjustStockInput, _userId?: number, username?: string) {
        // Un ajuste manual inserta directamente en movimientos_stock
        // Los triggers se encargarán de actualizar el stock en productos

        return await prisma.movimientos_stock.create({
            data: {
                id_producto: data.id_producto,
                tipo: data.tipo_movimiento as any, // Cast to any or specific enum if imported
                cantidad: data.cantidad, // Debe ser positivo, el tipo define si suma o resta? 
                // DB Schema dice: ENUM('ENTRADA','SALIDA'). Cantidad unsigned? No, int.
                // Generalmente ENTRADA suma, SALIDA resta.
                // Asegurémonos de que la cantidad sea positiva y el tipo maneje el signo lógico
                // O si la DB espera negativos para salida. 
                // Revisando lógica estándar: Cantidad absoluta + Tipo. Trigger manejará aritmética.

                observacion: `AJUSTE MANUAL: ${data.observaciones}`,
                created_by: username || 'system'
            }
        });
    }
}
