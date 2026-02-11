
import prisma from '../../config/database';

export class ReportesService {
    /**
     * Obtener KPIs principales (Tarjetas)
     */
    async getKpis() {
        const today = new Date();
        const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

        // 1. Valor Inventario: Suma de (stock_actual * precio_venta_base)
        // Nota: Asumimos precio_venta_base como valor referencial.
        const stockData = await prisma.productos.findMany({
            select: {
                stock_actual: true,
                precio_venta_base: true
            }
        });

        const valorInventario = stockData.reduce((acc, curr) => {
            const stock = curr.stock_actual || 0;
            const precio = Number(curr.precio_venta_base) || 0;
            return acc + (stock * precio);
        }, 0);

        // 2. Gasto en Requerimientos (Mes Actual)
        // Suma de (cantidad_solicitada * precio_proveedor) en requerimientos no anulados
        const requerimientosMes = await prisma.requerimiento_detalles.findMany({
            where: {
                requerimientos: {
                    fecha_emision: {
                        gte: startOfMonth,
                        lte: endOfMonth
                    },
                    estado: { not: 'ANULADO' }
                }
            },
            select: {
                cantidad_solicitada: true,
                precio_proveedor: true
            }
        });

        const gastoRequerimientos = requerimientosMes.reduce((acc, curr) => {
            return acc + (curr.cantidad_solicitada * Number(curr.precio_proveedor));
        }, 0);

        // 3. Valor Despachado (Mes Actual) - Ventas
        // Suma de (cantidad_despachada * precio_venta del producto) en despachos EN_TRANSITO o ENTREGADO
        const despachosMes = await prisma.despacho_detalles.findMany({
            where: {
                despachos: {
                    fecha_creacion: {
                        gte: startOfMonth,
                        lte: endOfMonth
                    },
                    estado: { in: ['EN_TRANSITO', 'ENTREGADO'] }
                }
            },
            include: {
                productos: {
                    select: { precio_venta_base: true }
                }
            }
        });

        const valorDespachado = despachosMes.reduce((acc, curr) => {
            const precio = Number(curr.productos.precio_venta_base) || 0;
            return acc + (curr.cantidad_despachada * precio);
        }, 0);

        // 4. Cantidad de Despachos (Volumen)
        const cantidadDespachos = await prisma.despachos.count({
            where: {
                fecha_creacion: {
                    gte: startOfMonth,
                    lte: endOfMonth
                },
                estado: { in: ['EN_TRANSITO', 'ENTREGADO'] }
            }
        });

        return {
            valorInventario,
            gastoRequerimientos,
            valorDespachado,
            cantidadDespachos,
            flujoNeto: valorDespachado - gastoRequerimientos
        };
    }

    /**
     * Obtener Top Minas por Valor Despachado (Histórico o Mes)
     */
    async getTopMinas() {
        // Agrupamos por mina y sumamos el valor
        // Prisma no soporta joins complejos en groupBy facilmente, haremos una query raw o lógica en memoria
        // Para simplicidad y flexibilidad, usaremos lógica en memoria optimizada (trayendo detalles necesarios)
        
        const despachos = await prisma.despacho_detalles.findMany({
            where: {
                despachos: {
                    estado: { in: ['EN_TRANSITO', 'ENTREGADO'] }
                }
            },
            include: {
                despachos: {
                    include: { minas: true }
                },
                productos: true
            }
        });

        const minasMap = new Map<string, number>();

        despachos.forEach(det => {
            const minaNombre = det.despachos.minas.nombre;
            const valor = det.cantidad_despachada * Number(det.productos.precio_venta_base || 0);
            
            minasMap.set(minaNombre, (minasMap.get(minaNombre) || 0) + valor);
        });

        // Convertir a array y ordenar
        const topMinas = Array.from(minasMap.entries())
            .map(([nombre, valor]) => ({ nombre, valor }))
            .sort((a, b) => b.valor - a.valor)
            .slice(0, 5);

        return topMinas;
    }

    /**
     * Obtener Tendencia Mensual (Últimos 6 meses)
     * Comparativa Gasto (Req) vs Venta (Desp)
     */
    async getTendenciaMensual() {
        const today = new Date();
        const sixMonthsAgo = new Date(today.getFullYear(), today.getMonth() - 5, 1);

        // 1. Obtener datos crudos
        const requerimientos = await prisma.requerimiento_detalles.findMany({
            where: {
                requerimientos: {
                    fecha_emision: { gte: sixMonthsAgo },
                    estado: { not: 'ANULADO' }
                }
            },
            select: {
                cantidad_solicitada: true,
                precio_proveedor: true,
                requerimientos: { select: { fecha_emision: true } }
            }
        });

        const despachos = await prisma.despacho_detalles.findMany({
            where: {
                despachos: {
                    fecha_creacion: { gte: sixMonthsAgo },
                    estado: { in: ['EN_TRANSITO', 'ENTREGADO'] }
                }
            },
            include: {
                productos: { select: { precio_venta_base: true } },
                despachos: { select: { fecha_creacion: true } }
            }
        });

        // 2. Agrupar por Mes-Año
        const tendenciaMap = new Map<string, { gastos: number, ventas: number }>();

        // Inicializar últimos 6 meses
        for (let i = 0; i < 6; i++) {
            const d = new Date(today.getFullYear(), today.getMonth() - i, 1);
            const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
            tendenciaMap.set(key, { gastos: 0, ventas: 0 });
        }

        // Sumar Gastos
        requerimientos.forEach(req => {
            if (!req.requerimientos.fecha_emision) return;
            const d = new Date(req.requerimientos.fecha_emision);
            const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
            
            if (tendenciaMap.has(key)) {
                const val = req.cantidad_solicitada * Number(req.precio_proveedor);
                tendenciaMap.get(key)!.gastos += val;
            }
        });

        // Sumar Ventas
        despachos.forEach(dsp => {
            if (!dsp.despachos.fecha_creacion) return;
            const d = new Date(dsp.despachos.fecha_creacion);
            const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
            
            if (tendenciaMap.has(key)) {
                const val = dsp.cantidad_despachada * Number(dsp.productos.precio_venta_base || 0);
                tendenciaMap.get(key)!.ventas += val;
            }
        });

        // Formatear respuesta orden cronológico
        return Array.from(tendenciaMap.entries())
            .sort((a, b) => a[0].localeCompare(b[0]))
            .map(([periodo, data]) => ({
                periodo,
                ...data
            }));
    }
}

export const reportesService = new ReportesService();
