-- =============================================================================
-- SCRIPT DE LIMPIEZA DE BASE DE DATOS - MADERA ERP (MEJORADO)
-- =============================================================================
-- ESTE SCRIPT ELIMINA TODA LA INFORMACIÓN TRANSACCIONAL DEL SISTEMA.
-- MANTIENE LAS TABLAS MAESTRAS (Productos, Proveedores, Minas, Usuarios, Medidas).
-- =============================================================================

-- Desactivar verificaciones de seguridad temporalmente
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0; -- Necesario si el servidor tiene activado el modo seguro

-- 1. Limpiar tablas de movimientos y detalles (Tablas hijas/nietas)
TRUNCATE TABLE movimientos_stock;
TRUNCATE TABLE viaje_detalles;
TRUNCATE TABLE despacho_detalles;
TRUNCATE TABLE requerimiento_detalles;
TRUNCATE TABLE auditoria; -- Opcional: Limpiar historial de auditoría
TRUNCATE TABLE precio_historico; -- Opcional: Limpiar historial de precios

-- 2. Limpiar tablas transaccionales principales (Tablas padres)
TRUNCATE TABLE despachos;
TRUNCATE TABLE viajes;
TRUNCATE TABLE requerimientos;

-- 3. Resetear el stock de los productos a 0
-- IMPORTANTE: TRUNCATE no dispara los triggers de resta, por eso forzamos a 0.
UPDATE productos SET stock_actual = 0 WHERE id_producto > 0;

-- 4. Reactivar verificaciones
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

-- 5. Verificación final (Opcional)
SELECT 'Limpieza completada. Stock de productos:' AS Mensaje;
SELECT nombre, stock_actual FROM productos LIMIT 10;

-- =============================================================================
-- FIN DEL SCRIPT
-- =============================================================================
