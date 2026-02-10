-- Actualizar vista v_stock_disponible para incluir precio_compra_sugerido e id_medida
DROP VIEW IF EXISTS v_stock_disponible;

CREATE VIEW v_stock_disponible AS
SELECT 
    p.id_producto,
    p.id_medida,
    p.nombre AS producto,
    m.descripcion AS medida,
    c.nombre AS clasificacion,
    p.id_clasificacion,
    p.stock_actual,
    p.precio_venta_base,
    COALESCE(
        (SELECT pp.precio_compra_sugerido 
         FROM producto_proveedores pp 
         WHERE pp.id_producto = p.id_producto 
           AND pp.activo = TRUE 
           AND pp.deleted_at IS NULL
         ORDER BY pp.fecha_actualizacion DESC 
         LIMIT 1),
        0
    ) AS precio_compra_sugerido,
    p.created_at,
    p.updated_at
FROM productos p
JOIN medidas m ON p.id_medida = m.id_medida
LEFT JOIN clasificaciones c ON p.id_clasificacion = c.id_clasificacion
WHERE p.deleted_at IS NULL;
