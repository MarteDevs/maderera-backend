use db_maderera_erp

-- =============================================
-- CARGA DE DATOS: PROVEEDORES
-- =============================================
INSERT INTO proveedores (nombre) VALUES 
('CARBAJAL'),
('MOTIL'),
('AL PATAZ'),
('BAILON'),
('MEZA'),
('LLAJARUNA'),
('DEPOSITO');


-- =============================================
-- CARGA DE DATOS: SUPERVISORES
-- =============================================
INSERT INTO supervisores (nombre) VALUES 
('TORRES'),
('TOBIAS'),
('WILSON'),
('ESGAR'),
('EDGAR'),
('JORGE'),
('JAIME'),
('JAVIER'),
('JOEL'),
('MARIO'),
('ARMAS'),
('DANTE'),
('GEINER'),
('SANDOVAL');


-- =============================================
-- CARGA DE DATOS: MINAS
-- =============================================
INSERT INTO minas (nombre, razon_social, ruc) VALUES 
('MANGALPA',        'VANIA',          '10443779146'),
('ESPERANZA',       'MARVIN',         '10442184301'),
('MANZANAS',        'TMSI',           '20539950551'),
('FRANCES',         'ROBERT',         '10443688302'),
('GUADALUPE',       'LUZDINA',        '10442841646'),
('ORMASAN',         'MARYLIN',        '10465613080'),
('SOLEDAD',         'VICTOR',         '10403673159'),
('IRACACUCHO 2',    'ROY',            '10703165775'),
('IRACACUCHO 1',    'CUARZO',         '20606112492'),
('SHIHUAPATA',      'RUFINO ALONSO',  '10804704901'),
('PORFIA 2',        'VANIA',          '10443779146'),
('CANTERA CHAGUAL', 'VICTOR',         '10403673159');




-- =============================================
-- 1. CARGA DE MEDIDAS (Complementario)
-- =============================================
INSERT IGNORE INTO medidas (descripcion) VALUES 
-- Cantoneras y Marchabantes
('2.40 MTS'), -- (Ya existía, pero aseguramos)
('3.00 MTS'), -- (Ya existía, pero aseguramos)

-- Durmientes / Escaleras
('8 Pulg x 1.50 MTS'), -- (Ya existía)

-- Postes Nuevos (4 Metros y otros diámetros)
('1.50 MTS x 8'),
('1.80 MTS x 6'), ('1.80 MTS x 7'), ('1.80 MTS x 8'),
('2.00 MTS x 6'), ('2.00 MTS x 7'), ('2.00 MTS x 8'),
('2.20 MTS x 6'), ('2.20 MTS x 7'), ('2.20 MTS x 8'),
('2.40 MTS x 5'), ('2.40 MTS x 6'), ('2.40 MTS x 7'), ('2.40 MTS x 8'), ('2.40 MTS x 9'),
('3.00 MTS x 6'), ('3.00 MTS x 7'), ('3.00 MTS x 8'), ('3.00 MTS x 9'),
('4.00 MTS x 7'), ('4.00 MTS x 8'), ('4.00 MTS x 9'),
('4x6'), -- Para el item 32

-- Tablas y Vigas
('3 MTS x 20CM x 1'),
('3 MTS x 20CM x 2'),
('6 MTS x 6'),

-- Parantes
('6.50 MTS'),
('4.00 MTS'); 
-- ('3.00 MTS' ya está arriba)




-- =============================================
-- 2. CARGA DE PRODUCTOS + PRECIO VENTA BASE
-- =============================================

-- CANTONERAS
INSERT INTO productos (nombre, id_medida, precio_venta_base) VALUES 
('CANTONERAS', (SELECT id_medida FROM medidas WHERE descripcion = '2.40 MTS' LIMIT 1), 17.00),
('CANTONERAS', (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS' LIMIT 1), 18.00);

-- DURMIENTE Y ESCALERA
INSERT INTO productos (nombre, id_medida, precio_venta_base) VALUES 
('DURMIENTE', (SELECT id_medida FROM medidas WHERE descripcion = '8 Pulg x 1.50 MTS' LIMIT 1), 40.00),
('ESCALERA',  (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS' LIMIT 1), 72.00);

-- MARCHABANTES
INSERT INTO productos (nombre, id_medida, precio_venta_base) VALUES 
('MARCHABANTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.40 MTS' LIMIT 1), 19.00),
('MARCHABANTES', (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS' LIMIT 1), 22.00);

-- POSTES (1.50 a 2.00)
INSERT INTO productos (nombre, id_medida, precio_venta_base) VALUES 
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '1.50 MTS x 8' LIMIT 1), 27.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '1.80 MTS x 7' LIMIT 1), 26.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '1.80 MTS x 6' LIMIT 1), 26.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '1.80 MTS x 8' LIMIT 1), 26.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.00 MTS x 6' LIMIT 1), 0.00), -- Sin precio venta en lista
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.00 MTS x 7' LIMIT 1), 38.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.00 MTS x 8' LIMIT 1), 38.00);

-- POSTES (2.20 a 2.40)
INSERT INTO productos (nombre, id_medida, precio_venta_base) VALUES 
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.20 MTS x 6' LIMIT 1), 0.00), -- Sin precio venta en lista
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.20 MTS x 7' LIMIT 1), 41.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.20 MTS x 8' LIMIT 1), 41.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.40 MTS x 5' LIMIT 1), 34.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.40 MTS x 6' LIMIT 1), 34.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.40 MTS x 7' LIMIT 1), 42.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.40 MTS x 8' LIMIT 1), 42.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '2.40 MTS x 9' LIMIT 1), 42.00);

-- POSTES (3.00 a 4.00)
INSERT INTO productos (nombre, id_medida, precio_venta_base) VALUES 
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS x 6' LIMIT 1), 44.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS x 7' LIMIT 1), 60.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS x 8' LIMIT 1), 60.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS x 9' LIMIT 1), 60.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '4.00 MTS x 7' LIMIT 1), 72.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '4.00 MTS x 8' LIMIT 1), 72.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '4.00 MTS x 9' LIMIT 1), 72.00);

-- TABLAS, VIGAS y ESPECIALES
INSERT INTO productos (nombre, id_medida, precio_venta_base) VALUES 
('TABLAS', (SELECT id_medida FROM medidas WHERE descripcion = '3 MTS x 20CM x 1' LIMIT 1), 30.00),
('TABLAS', (SELECT id_medida FROM medidas WHERE descripcion = '3 MTS x 20CM x 2' LIMIT 1), 32.00),
('VIGAS DE MADERA', (SELECT id_medida FROM medidas WHERE descripcion = '6 MTS x 6' LIMIT 1), 55.00),
('POSTES', (SELECT id_medida FROM medidas WHERE descripcion = '4x6' LIMIT 1), 62.00),
('PARANTES', (SELECT id_medida FROM medidas WHERE descripcion = '6.50 MTS' LIMIT 1), 22.00),
('PARANTES', (SELECT id_medida FROM medidas WHERE descripcion = '4.00 MTS' LIMIT 1), 18.00),
('PARANTES DELGADOS', (SELECT id_medida FROM medidas WHERE descripcion = '3.00 MTS' LIMIT 1), 10.00);




-- =============================================
-- 3. CARGA DE PRECIOS PARA 'CARBAJAL'
-- =============================================

-- Capturamos el ID de Carbajal en una variable para no equivocarnos
SET @id_prov = (SELECT id_proveedor FROM proveedores WHERE nombre = 'CARBAJAL' LIMIT 1);

INSERT INTO producto_proveedores (id_proveedor, id_producto, precio_compra_sugerido)
SELECT 
    @id_prov, 
    p.id_producto, 
    CASE 
        -- Asignamos precio según Nombre y Medida (Lógica exacta de tu Excel)
        WHEN p.nombre = 'CANTONERAS' AND m.descripcion = '2.40 MTS' THEN 13.00
        WHEN p.nombre = 'CANTONERAS' AND m.descripcion = '3.00 MTS' THEN 14.00
        WHEN p.nombre = 'DURMIENTE' AND m.descripcion = '8 Pulg x 1.50 MTS' THEN 35.00
        WHEN p.nombre = 'ESCALERA' AND m.descripcion = '3.00 MTS' THEN 60.00
        WHEN p.nombre = 'MARCHABANTES' AND m.descripcion = '2.40 MTS' THEN 17.00
        WHEN p.nombre = 'MARCHABANTES' AND m.descripcion = '3.00 MTS' THEN 19.00
        
        -- Postes 1.50 - 1.80
        WHEN p.nombre = 'POSTES' AND m.descripcion = '1.50 MTS x 8' THEN 25.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '1.80 MTS x 7' THEN 24.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '1.80 MTS x 6' THEN 23.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '1.80 MTS x 8' THEN 23.00
        
        -- Postes 2.00 - 2.20
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.00 MTS x 6' THEN 28.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.00 MTS x 7' THEN 33.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.00 MTS x 8' THEN 33.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.20 MTS x 6' THEN 30.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.20 MTS x 7' THEN 35.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.20 MTS x 8' THEN 35.00
        
        -- Postes 2.40
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.40 MTS x 5' THEN 23.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.40 MTS x 6' THEN 24.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.40 MTS x 7' THEN 38.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.40 MTS x 8' THEN 38.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '2.40 MTS x 9' THEN 38.00
        
        -- Postes 3.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '3.00 MTS x 6' THEN 39.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '3.00 MTS x 7' THEN 55.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '3.00 MTS x 8' THEN 55.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '3.00 MTS x 9' THEN 55.00
        
        -- Postes 4.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '4.00 MTS x 7' THEN 67.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '4.00 MTS x 8' THEN 67.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '4.00 MTS x 9' THEN 67.00
        
        -- Varios
        WHEN p.nombre = 'TABLAS' AND m.descripcion = '3 MTS x 20CM x 1' THEN 27.00
        WHEN p.nombre = 'TABLAS' AND m.descripcion = '3 MTS x 20CM x 2' THEN 29.00
        WHEN p.nombre = 'VIGAS DE MADERA' AND m.descripcion = '6 MTS x 6' THEN 50.00
        WHEN p.nombre = 'POSTES' AND m.descripcion = '4x6' THEN 57.00
        WHEN p.nombre = 'PARANTES' AND m.descripcion = '6.50 MTS' THEN 21.00
        WHEN p.nombre = 'PARANTES' AND m.descripcion = '4.00 MTS' THEN 17.00
        WHEN p.nombre = 'PARANTES DELGADOS' AND m.descripcion = '3.00 MTS' THEN 1.00
        
        ELSE 0 -- Seguridad por si falta algo
    END
FROM productos p
JOIN medidas m ON p.id_medida = m.id_medida;