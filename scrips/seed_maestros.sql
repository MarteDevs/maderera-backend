-- ============================================
-- SEED DATA PARA MAESTROS
-- ============================================
-- Este script inserta datos de prueba para medidas, clasificaciones,
-- proveedores, minas, supervisores y productos

-- ============================================
-- MEDIDAS
-- ============================================
INSERT INTO medidas (descripcion, largo_mts, diametro_min_cm, diametro_max_cm) VALUES
('2.4m x 10-15cm', 2.400, 10.00, 15.00),
('3.0m x 15-20cm', 3.000, 15.00, 20.00),
('2.4m x 20-25cm', 2.400, 20.00, 25.00),
('3.0m x 20-25cm', 3.000, 20.00, 25.00),
('2.4m x 25-30cm', 2.400, 25.00, 30.00);

-- ============================================
-- CLASIFICACIONES
-- ============================================
INSERT INTO clasificaciones (nombre, descripcion, activo) VALUES
('Primera', 'Madera de primera calidad - Sin nudos, recta', true),
('Segunda', 'Madera de segunda calidad - Nudos pequeños permitidos', true),
('Tercera', 'Madera de tercera calidad - Para uso general', true);

-- ============================================
-- PROVEEDORES
-- ============================================
INSERT INTO proveedores (nombre, razon_social, ruc, contacto, telefono) VALUES
('Maderera San Juan', 'Maderera San Juan S.A.C.', '20123456789', 'Juan Pérez', '987654321'),
('Forestal Los Andes', 'Forestal Los Andes E.I.R.L.', '20234567890', 'María González', '976543210'),
('Eucalipto Premium SAC', 'Eucalipto Premium S.A.C.', '20345678901', 'Carlos Ramírez', '965432109');

-- ============================================
-- MINAS
-- ============================================
INSERT INTO minas (nombre, razon_social, ruc, ubicacion, contacto) VALUES
('Mina El Bosque', 'Mina El Bosque E.I.R.L.', '20987654321', 'Km 45 Carretera Central', 'Pedro López'),
('Mina La Esperanza', 'Mina La Esperanza S.A.', '20876543210', 'Km 60 Carretera Norte', 'Ana Torres'),
('Mina San Miguel', 'Mina San Miguel S.R.L.', '20765432109', 'Km 35 Carretera Sur', 'Luis Mendoza');

-- ============================================
-- SUPERVISORES
-- ============================================
INSERT INTO supervisores (nombre, telefono, email) VALUES
('Carlos Ramírez', '912345678', 'carlos.ramirez@example.com'),
('Ana Torres', '923456789', 'ana.torres@example.com'),
('Luis Mendoza', '934567890', 'luis.mendoza@example.com');

-- ============================================
-- PRODUCTOS
-- ============================================
-- Nota: Asegúrate de que los IDs de medida y clasificación coincidan con los insertados arriba
INSERT INTO productos (nombre, id_medida, id_clasificacion, precio_venta_base, stock_actual, observaciones) VALUES
('Poste Eucalipto 2.4m Primera', 1, 1, 150.00, 100, 'Stock inicial - Primera calidad'),
('Poste Eucalipto 3.0m Primera', 2, 1, 180.00, 80, 'Stock inicial - Primera calidad'),
('Poste Eucalipto 2.4m Segunda', 3, 2, 120.00, 150, 'Stock inicial - Segunda calidad'),
('Poste Eucalipto 3.0m Segunda', 4, 2, 140.00, 120, 'Stock inicial - Segunda calidad'),
('Poste Eucalipto 2.4m Tercera', 5, 3, 90.00, 200, 'Stock inicial - Tercera calidad');

-- ============================================
-- VERIFICACIÓN
-- ============================================
-- Ejecuta estas consultas para verificar que los datos se insertaron correctamente

-- SELECT * FROM medidas WHERE deleted_at IS NULL;
-- SELECT * FROM clasificaciones WHERE deleted_at IS NULL;
-- SELECT * FROM proveedores WHERE deleted_at IS NULL;
-- SELECT * FROM minas WHERE deleted_at IS NULL;
-- SELECT * FROM supervisores WHERE deleted_at IS NULL;
-- SELECT * FROM productos WHERE deleted_at IS NULL;
