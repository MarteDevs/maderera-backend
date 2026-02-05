-- ==========================================================
-- SCRIPT DE BASE DE DATOS MEJORADO - ERP MADERERA / POSTES
-- Versión: OPTIMIZADA v2.0
-- Compatible: MySQL 8.0+
-- Mejoras: Índices, Vistas, SPs adicionales, Soft Deletes, Auditoría mejorada
-- ==========================================================

DROP DATABASE IF EXISTS db_maderera_erp;
CREATE DATABASE db_maderera_erp 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;
USE db_maderera_erp;

-- ==========================================================
-- 2. TABLAS MAESTRAS
-- ==========================================================

CREATE TABLE clasificaciones (
    id_clasificacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(50) NOT NULL COMMENT '1ª calidad, 2ª, Recuperación, Mixto, etc.',
    descripcion  VARCHAR(150) NULL,
    activo       BOOLEAN DEFAULT TRUE,
    deleted_at   DATETIME NULL COMMENT 'Soft delete',
    UNIQUE KEY uk_nombre_clasif (nombre)
) ENGINE=InnoDB;

CREATE TABLE medidas (
    id_medida     INT AUTO_INCREMENT PRIMARY KEY,
    descripcion   VARCHAR(100) NOT NULL COMMENT 'Ej: "2.20 m x 7-9 cm Ø"',
    largo_mts     DECIMAL(6,3) NULL,
    diametro_min_cm DECIMAL(5,2) NULL,
    diametro_max_cm DECIMAL(5,2) NULL,
    deleted_at    DATETIME NULL,
    UNIQUE KEY uk_descripcion_med (descripcion)
) ENGINE=InnoDB;

CREATE TABLE productos (
    id_producto      INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(80) NOT NULL,
    id_medida        INT NOT NULL,
    id_clasificacion INT NULL,
    precio_venta_base DECIMAL(10,2) DEFAULT 0.00 CHECK (precio_venta_base >= 0),
    stock_actual     INT DEFAULT 0 COMMENT 'Cache – modificar solo vía triggers',
    observaciones    VARCHAR(250) NULL,
    
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by       VARCHAR(80) NULL,
    updated_by       VARCHAR(80) NULL,
    deleted_at       DATETIME NULL,
    
    -- MEJORA: Constraint para evitar stock negativo
    CONSTRAINT chk_stock_positivo CHECK (stock_actual >= 0),
    CONSTRAINT fk_prod_medida        FOREIGN KEY (id_medida)        REFERENCES medidas(id_medida),
    CONSTRAINT fk_prod_clasificacion FOREIGN KEY (id_clasificacion) REFERENCES clasificaciones(id_clasificacion),
    
    -- MEJORA: Índice para búsquedas por nombre
    INDEX idx_prod_nombre (nombre),
    INDEX idx_prod_stock (stock_actual)
) ENGINE=InnoDB;

CREATE TABLE minas (
    id_mina       INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    razon_social  VARCHAR(150) NULL,
    ruc           VARCHAR(20) NULL,
    ubicacion     VARCHAR(150) NULL,
    contacto      VARCHAR(100) NULL,
    deleted_at    DATETIME NULL,
    UNIQUE KEY uk_nombre_mina (nombre)
) ENGINE=InnoDB;

CREATE TABLE proveedores (
    id_proveedor  INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    razon_social  VARCHAR(150) NULL COMMENT 'Agregado para consistencia',
    ruc           VARCHAR(20) NULL,
    contacto      VARCHAR(100) NULL,
    telefono      VARCHAR(20) NULL,
    deleted_at    DATETIME NULL,
    UNIQUE KEY uk_nombre_prov (nombre)
) ENGINE=InnoDB;

CREATE TABLE supervisores (
    id_supervisor INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    telefono      VARCHAR(20) NULL,
    email         VARCHAR(120) NULL,
    deleted_at    DATETIME NULL,
    UNIQUE KEY uk_nombre_sup (nombre)
) ENGINE=InnoDB;

CREATE TABLE producto_proveedores (
    id_catalogo            INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor           INT NOT NULL,
    id_producto            INT NOT NULL,
    precio_compra_sugerido DECIMAL(10,2) NOT NULL CHECK (precio_compra_sugerido >= 0),
    fecha_actualizacion    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    activo                 BOOLEAN DEFAULT TRUE,
    
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by  VARCHAR(80) NULL,
    updated_by  VARCHAR(80) NULL,
    deleted_at  DATETIME NULL,
    
    UNIQUE KEY uk_prod_prov_unique (id_proveedor, id_producto),
    CONSTRAINT fk_cat_prov FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
    CONSTRAINT fk_cat_prod FOREIGN KEY (id_producto)  REFERENCES productos(id_producto),
    
    -- MEJORA: Índice para búsquedas por proveedor
    INDEX idx_cat_proveedor (id_proveedor, activo)
) ENGINE=InnoDB;

-- NUEVA TABLA: Histórico de cambios de precios
CREATE TABLE precio_historico (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_catalogo  INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo    DECIMAL(10,2) NOT NULL,
    fecha_cambio    DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_cambio  VARCHAR(80) NULL,
    
    CONSTRAINT fk_hist_cat FOREIGN KEY (id_catalogo) REFERENCES producto_proveedores(id_catalogo),
    INDEX idx_hist_fecha (id_catalogo, fecha_cambio DESC)
) ENGINE=InnoDB COMMENT 'Auditoría de cambios de precios';

-- ==========================================================
-- 3. REQUERIMIENTOS
-- ==========================================================

CREATE TABLE requerimientos (
    id_requerimiento INT AUTO_INCREMENT PRIMARY KEY,
    codigo           VARCHAR(20) UNIQUE NOT NULL COMMENT 'Ej: REQ-2025-0001',
    fecha_emision    DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_prometida  DATE NULL,
    
    id_proveedor  INT NOT NULL,
    id_mina       INT NOT NULL,
    id_supervisor INT NOT NULL,
    
    estado        ENUM('PENDIENTE','PARCIAL','COMPLETADO','ANULADO','RECHAZADO') DEFAULT 'PENDIENTE',
    observaciones TEXT NULL,
    motivo_anulacion TEXT NULL COMMENT 'Obligatorio si estado=ANULADO',
    
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by    VARCHAR(80) NULL,
    updated_by    VARCHAR(80) NULL,
    deleted_at    DATETIME NULL,
    
    CONSTRAINT fk_req_prov  FOREIGN KEY (id_proveedor)  REFERENCES proveedores(id_proveedor),
    CONSTRAINT fk_req_mina  FOREIGN KEY (id_mina)       REFERENCES minas(id_mina),
    CONSTRAINT fk_req_sup   FOREIGN KEY (id_supervisor) REFERENCES supervisores(id_supervisor),
    
    -- MEJORA: Índices para consultas frecuentes
    INDEX idx_req_estado (estado),
    INDEX idx_req_fecha (fecha_emision DESC),
    INDEX idx_req_proveedor (id_proveedor),
    INDEX idx_req_mina (id_mina),
    INDEX idx_req_estado_fecha (estado, fecha_emision DESC)
) ENGINE=InnoDB;

CREATE TABLE requerimiento_detalles (
    id_detalle          INT AUTO_INCREMENT PRIMARY KEY,
    id_requerimiento    INT NOT NULL,
    id_producto         INT NOT NULL,
    
    cantidad_solicitada INT NOT NULL CHECK (cantidad_solicitada > 0),
    cantidad_entregada  INT DEFAULT 0 CHECK (cantidad_entregada >= 0),
    unidad_medida       VARCHAR(20) DEFAULT 'UND',
    
    precio_proveedor    DECIMAL(10,2) NOT NULL CHECK (precio_proveedor >= 0),
    precio_mina         DECIMAL(10,2) NOT NULL COMMENT 'Validado por trigger: debe ser >= precio_proveedor',
    
    observacion         VARCHAR(250) NULL,
    
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by  VARCHAR(80) NULL,
    updated_by  VARCHAR(80) NULL,
    
    INDEX idx_det_producto (id_producto),
    INDEX idx_det_req (id_requerimiento),
    
    CONSTRAINT fk_det_req FOREIGN KEY (id_requerimiento) REFERENCES requerimientos(id_requerimiento) ON DELETE CASCADE,
    CONSTRAINT fk_det_prod FOREIGN KEY (id_producto)     REFERENCES productos(id_producto)
) ENGINE=InnoDB;

-- ==========================================================
-- 4. VIAJES
-- ==========================================================

CREATE TABLE viajes (
    id_viaje         INT AUTO_INCREMENT PRIMARY KEY,
    id_requerimiento INT NOT NULL,
    numero_viaje     INT NOT NULL,
    
    fecha_salida     DATETIME NULL,
    fecha_ingreso    DATETIME DEFAULT CURRENT_TIMESTAMP,
    placa_vehiculo   VARCHAR(20) NULL,
    conductor        VARCHAR(100) NULL,
    observaciones    TEXT NULL,
    
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by       VARCHAR(80) NULL,
    updated_by       VARCHAR(80) NULL,
    
    UNIQUE KEY uk_viaje_req_num (id_requerimiento, numero_viaje),
    CONSTRAINT fk_via_req FOREIGN KEY (id_requerimiento) REFERENCES requerimientos(id_requerimiento) ON DELETE CASCADE,
    
    -- MEJORA: Índice para consultas por fecha
    INDEX idx_viaje_fecha (fecha_ingreso DESC)
) ENGINE=InnoDB;

CREATE TABLE viaje_detalles (
    id_viaje_detalle     INT AUTO_INCREMENT PRIMARY KEY,
    id_viaje             INT NOT NULL,
    id_detalle_requerimiento INT NOT NULL,
    
    cantidad_recibida    INT NOT NULL CHECK (cantidad_recibida > 0),
    estado_entrega       ENUM('OK','RECHAZADO','PARCIAL','MUESTRA','DAÑADO') DEFAULT 'OK',
    observacion          VARCHAR(250) NULL,
    
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by  VARCHAR(80) NULL,
    updated_by  VARCHAR(80) NULL,
    
    CONSTRAINT fk_vdet_via FOREIGN KEY (id_viaje) REFERENCES viajes(id_viaje) ON DELETE CASCADE,
    CONSTRAINT fk_vdet_det FOREIGN KEY (id_detalle_requerimiento) REFERENCES requerimiento_detalles(id_detalle),
    
    INDEX idx_vdet_viaje (id_viaje)
) ENGINE=InnoDB;

-- ==========================================================
-- 5. KARDEX / STOCK
-- ==========================================================

CREATE TABLE movimientos_stock (
    id_movimiento    INT AUTO_INCREMENT PRIMARY KEY,
    id_producto      INT NOT NULL,
    
    tipo             ENUM('ENTRADA','SALIDA','AJUSTE_POS','AJUSTE_NEG','DEVOLUCION','AJUSTE_MANUAL') NOT NULL,
    cantidad         INT NOT NULL CHECK (cantidad <> 0),
    
    id_viaje         INT NULL,
    id_requerimiento INT NULL,
    id_detalle_req   INT NULL,
    
    fecha            DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_registro VARCHAR(80) NULL COMMENT 'Quién registró (para auditoría rápida)',
    observacion      VARCHAR(250) NULL,
    
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by  VARCHAR(80) NULL,
    updated_by  VARCHAR(80) NULL,
    
    INDEX idx_mov_prod_fecha (id_producto, fecha DESC),
    INDEX idx_mov_viaje (id_viaje),
    INDEX idx_mov_tipo (tipo),
    
    CONSTRAINT fk_mov_prod  FOREIGN KEY (id_producto)      REFERENCES productos(id_producto),
    CONSTRAINT fk_mov_via   FOREIGN KEY (id_viaje)         REFERENCES viajes(id_viaje),
    CONSTRAINT fk_mov_det   FOREIGN KEY (id_detalle_req)   REFERENCES requerimiento_detalles(id_detalle),
    CONSTRAINT fk_mov_req   FOREIGN KEY (id_requerimiento) REFERENCES requerimientos(id_requerimiento) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==========================================================
-- 6. USUARIOS Y SEGURIDAD
-- ==========================================================

CREATE TABLE usuarios (
    id_usuario       INT AUTO_INCREMENT PRIMARY KEY,
    username         VARCHAR(50) NOT NULL UNIQUE,
    password_hash    VARCHAR(255) NOT NULL COMMENT 'Bcrypt con 12 rounds',
    nombre_completo  VARCHAR(100) NOT NULL,
    rol              ENUM('ADMIN', 'LOGISTICA', 'SUPERVISOR', 'MINA') DEFAULT 'SUPERVISOR',
    activo           BOOLEAN DEFAULT TRUE,
    
    -- Opcional: vincular con supervisor del sistema
    id_supervisor    INT NULL,
    
    -- MEJORA: Campos para seguridad
    ultimo_login     DATETIME NULL,
    intentos_fallidos INT DEFAULT 0,
    bloqueado_hasta  DATETIME NULL,
    
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_usu_sup FOREIGN KEY (id_supervisor) REFERENCES supervisores(id_supervisor),
    INDEX idx_usuario_activo (activo)
) ENGINE=InnoDB;

-- NUEVA TABLA: Historial de contraseñas (para evitar reutilización)
CREATE TABLE password_history (
    id_history INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_passhist_user FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    INDEX idx_hist_user (id_usuario, fecha_cambio DESC)
) ENGINE=InnoDB;

-- ==========================================================
-- 7. AUDITORÍA MEJORADA
-- ==========================================================

CREATE TABLE auditoria (
    id_auditoria   INT AUTO_INCREMENT PRIMARY KEY,
    tabla          VARCHAR(80) NOT NULL,
    id_registro    INT NOT NULL,
    accion         ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    usuario        VARCHAR(80) NOT NULL,
    fecha          DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- MEJORA: Capturar valores anteriores y nuevos
    valores_antes  TEXT NULL COMMENT 'JSON con valores antes del cambio',
    valores_despues TEXT NULL COMMENT 'JSON con valores después del cambio',
    ip_address     VARCHAR(45) NULL COMMENT 'IPv4 o IPv6',
    
    INDEX idx_aud_tabla_fecha (tabla, fecha DESC),
    INDEX idx_aud_usuario (usuario)
) ENGINE=InnoDB COMMENT 'Registro completo de cambios críticos';

-- ==========================================================
-- 8. VISTAS ESTRATÉGICAS (MEJORA DE PERFORMANCE)
-- ==========================================================

-- VISTA: Stock disponible con información completa
CREATE VIEW v_stock_disponible AS
SELECT 
    p.id_producto,
    p.nombre AS producto,
    m.descripcion AS medida,
    c.nombre AS clasificacion,
    p.stock_actual,
    p.precio_venta_base,
    p.created_at,
    p.updated_at
FROM productos p
JOIN medidas m ON p.id_medida = m.id_medida
LEFT JOIN clasificaciones c ON p.id_clasificacion = c.id_clasificacion
WHERE p.deleted_at IS NULL;

-- VISTA: Requerimientos con progreso de cumplimiento
CREATE VIEW v_requerimientos_progreso AS
SELECT 
    r.id_requerimiento,
    r.codigo,
    r.fecha_emision,
    r.estado,
    prov.nombre AS proveedor,
    m.nombre AS mina,
    s.nombre AS supervisor,
    SUM(rd.cantidad_solicitada) AS total_solicitado,
    SUM(rd.cantidad_entregada) AS total_entregado,
    ROUND((SUM(rd.cantidad_entregada) / SUM(rd.cantidad_solicitada)) * 100, 2) AS porcentaje_cumplimiento
FROM requerimientos r
JOIN proveedores prov ON r.id_proveedor = prov.id_proveedor
JOIN minas m ON r.id_mina = m.id_mina
JOIN supervisores s ON r.id_supervisor = s.id_supervisor
JOIN requerimiento_detalles rd ON r.id_requerimiento = rd.id_requerimiento
WHERE r.deleted_at IS NULL
GROUP BY r.id_requerimiento, r.codigo, r.fecha_emision, r.estado, prov.nombre, m.nombre, s.nombre;

-- VISTA: Kardex completo (movimientos con información de producto)
CREATE VIEW v_kardex_completo AS
SELECT 
    ms.id_movimiento,
    ms.fecha,
    p.nombre AS producto,
    m.descripcion AS medida,
    ms.tipo,
    ms.cantidad,
    ms.observacion,
    ms.usuario_registro,
    v.codigo AS codigo_viaje,
    req.codigo AS codigo_requerimiento
FROM movimientos_stock ms
JOIN productos p ON ms.id_producto = p.id_producto
JOIN medidas m ON p.id_medida = m.id_medida
LEFT JOIN viajes v ON ms.id_viaje = v.id_viaje
LEFT JOIN requerimientos req ON ms.id_requerimiento = req.id_requerimiento
ORDER BY ms.fecha DESC;

-- VISTA: Precios activos por proveedor
CREATE VIEW v_precios_proveedores AS
SELECT 
    pp.id_catalogo,
    prov.nombre AS proveedor,
    prod.nombre AS producto,
    m.descripcion AS medida,
    pp.precio_compra_sugerido,
    pp.fecha_actualizacion
FROM producto_proveedores pp
JOIN proveedores prov ON pp.id_proveedor = prov.id_proveedor
JOIN productos prod ON pp.id_producto = prod.id_producto
JOIN medidas m ON prod.id_medida = m.id_medida
WHERE pp.activo = TRUE 
  AND pp.deleted_at IS NULL
  AND prov.deleted_at IS NULL
  AND prod.deleted_at IS NULL;

-- ==========================================================
-- 9. TRIGGERS COMPLETOS (VALIDACIONES Y AUTOMATIZACIONES)
-- ==========================================================

DELIMITER //

-- ============================
-- VALIDACIÓN DE PRECIOS
-- ============================

CREATE TRIGGER trg_validar_precios_insert
BEFORE INSERT ON requerimiento_detalles FOR EACH ROW
BEGIN
    IF NEW.precio_mina < NEW.precio_proveedor THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio_mina debe ser mayor o igual al precio_proveedor';
    END IF;
END //

CREATE TRIGGER trg_validar_precios_update
BEFORE UPDATE ON requerimiento_detalles FOR EACH ROW
BEGIN
    IF NEW.precio_mina < NEW.precio_proveedor THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio_mina debe ser mayor o igual al precio_proveedor';
    END IF;
END //

-- ============================
-- VIAJE_DETALLES: Actualizar cantidad_entregada
-- ============================

CREATE TRIGGER trg_entregada_insert
AFTER INSERT ON viaje_detalles FOR EACH ROW
BEGIN
    IF NEW.estado_entrega IN ('OK', 'PARCIAL', 'MUESTRA') THEN
        UPDATE requerimiento_detalles 
        SET cantidad_entregada = cantidad_entregada + NEW.cantidad_recibida
        WHERE id_detalle = NEW.id_detalle_requerimiento;
    END IF;
END //

CREATE TRIGGER trg_entregada_update
AFTER UPDATE ON viaje_detalles FOR EACH ROW
BEGIN
    DECLARE diff INT DEFAULT 0;
    DECLARE old_count INT DEFAULT 0;
    DECLARE new_count INT DEFAULT 0;
    
    IF OLD.estado_entrega IN ('OK', 'PARCIAL', 'MUESTRA') THEN
        SET old_count = OLD.cantidad_recibida;
    END IF;
    
    IF NEW.estado_entrega IN ('OK', 'PARCIAL', 'MUESTRA') THEN
        SET new_count = NEW.cantidad_recibida;
    END IF;
    
    SET diff = new_count - old_count;
    
    UPDATE requerimiento_detalles 
    SET cantidad_entregada = cantidad_entregada + diff
    WHERE id_detalle = NEW.id_detalle_requerimiento;
END //

CREATE TRIGGER trg_entregada_delete
AFTER DELETE ON viaje_detalles FOR EACH ROW
BEGIN
    IF OLD.estado_entrega IN ('OK', 'PARCIAL', 'MUESTRA') THEN
        UPDATE requerimiento_detalles 
        SET cantidad_entregada = cantidad_entregada - OLD.cantidad_recibida
        WHERE id_detalle = OLD.id_detalle_requerimiento;
    END IF;
END //

-- ============================
-- MOVIMIENTOS_STOCK: Actualizar stock_actual
-- ============================

CREATE TRIGGER trg_stock_insert
AFTER INSERT ON movimientos_stock FOR EACH ROW
BEGIN
    IF NEW.tipo IN ('ENTRADA','AJUSTE_POS','DEVOLUCION') THEN
        UPDATE productos SET stock_actual = stock_actual + NEW.cantidad WHERE id_producto = NEW.id_producto;
    ELSE
        UPDATE productos SET stock_actual = stock_actual - ABS(NEW.cantidad) WHERE id_producto = NEW.id_producto;
    END IF;
END //

CREATE TRIGGER trg_stock_update
AFTER UPDATE ON movimientos_stock FOR EACH ROW
BEGIN
    -- Revertir el efecto del valor antiguo
    IF OLD.tipo IN ('ENTRADA','AJUSTE_POS','DEVOLUCION') THEN
        UPDATE productos SET stock_actual = stock_actual - OLD.cantidad WHERE id_producto = OLD.id_producto;
    ELSE
        UPDATE productos SET stock_actual = stock_actual + ABS(OLD.cantidad) WHERE id_producto = OLD.id_producto;
    END IF;
    
    -- Aplicar el efecto del valor nuevo
    IF NEW.tipo IN ('ENTRADA','AJUSTE_POS','DEVOLUCION') THEN
        UPDATE productos SET stock_actual = stock_actual + NEW.cantidad WHERE id_producto = NEW.id_producto;
    ELSE
        UPDATE productos SET stock_actual = stock_actual - ABS(NEW.cantidad) WHERE id_producto = NEW.id_producto;
    END IF;
END //

CREATE TRIGGER trg_stock_delete
AFTER DELETE ON movimientos_stock FOR EACH ROW
BEGIN
    IF OLD.tipo IN ('ENTRADA','AJUSTE_POS','DEVOLUCION') THEN
        UPDATE productos SET stock_actual = stock_actual - OLD.cantidad WHERE id_producto = OLD.id_producto;
    ELSE
        UPDATE productos SET stock_actual = stock_actual + ABS(OLD.cantidad) WHERE id_producto = OLD.id_producto;
    END IF;
END //

-- ============================
-- AUDITORÍA AUTOMÁTICA DE CAMBIOS DE PRECIOS
-- ============================

CREATE TRIGGER trg_precio_cambio
AFTER UPDATE ON producto_proveedores FOR EACH ROW
BEGIN
    IF OLD.precio_compra_sugerido <> NEW.precio_compra_sugerido THEN
        INSERT INTO precio_historico (id_catalogo, precio_anterior, precio_nuevo, usuario_cambio)
        VALUES (NEW.id_catalogo, OLD.precio_compra_sugerido, NEW.precio_compra_sugerido, NEW.updated_by);
    END IF;
END //

DELIMITER ;

-- ==========================================================
-- 10. PROCEDIMIENTOS ALMACENADOS
-- ==========================================================

DELIMITER //

-- SP 1: Generar código de requerimiento automático
CREATE PROCEDURE sp_generar_codigo_requerimiento(OUT p_codigo VARCHAR(20))
BEGIN
    DECLARE v_anio CHAR(4);
    DECLARE v_ultimo INT DEFAULT 0;
    
    SET v_anio = YEAR(CURRENT_DATE());
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(codigo, 10) AS UNSIGNED)), 0) + 1
    INTO v_ultimo
    FROM requerimientos
    WHERE codigo LIKE CONCAT('REQ-', v_anio, '-%');
    
    SET p_codigo = CONCAT('REQ-', v_anio, '-', LPAD(v_ultimo, 4, '0'));
END //

-- NUEVO SP 2: Calcular porcentaje de cumplimiento de requerimiento
CREATE PROCEDURE sp_calcular_cumplimiento(
    IN p_id_req INT,
    OUT p_porcentaje DECIMAL(5,2)
)
BEGIN
    SELECT ROUND((SUM(cantidad_entregada) / SUM(cantidad_solicitada)) * 100, 2)
    INTO p_porcentaje
    FROM requerimiento_detalles
    WHERE id_requerimiento = p_id_req;
END //

-- NUEVO SP 3: Registrar viaje completo (transacción atómica)
CREATE PROCEDURE sp_registrar_viaje(
    IN p_id_req INT,
    IN p_placa VARCHAR(20),
    IN p_conductor VARCHAR(100),
    IN p_usuario VARCHAR(80),
    OUT p_id_viaje INT
)
BEGIN
    DECLARE v_numero_viaje INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar viaje';
    END;
    
    START TRANSACTION;
    
    -- Calcular número de viaje
    SELECT COALESCE(MAX(numero_viaje), 0) + 1
    INTO v_numero_viaje
    FROM viajes
    WHERE id_requerimiento = p_id_req;
    
    -- Insertar viaje
    INSERT INTO viajes (id_requerimiento, numero_viaje, placa_vehiculo, conductor, created_by)
    VALUES (p_id_req, v_numero_viaje, p_placa, p_conductor, p_usuario);
    
    SET p_id_viaje = LAST_INSERT_ID();
    
    COMMIT;
END //

-- NUEVO SP 4: Soft delete seguro
CREATE PROCEDURE sp_soft_delete_proveedor(
    IN p_id_prov INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_tiene_movimientos INT;
    
    -- Verificar si tiene movimientos
    SELECT COUNT(*)
    INTO v_tiene_movimientos
    FROM requerimientos
    WHERE id_proveedor = p_id_prov;
    
    IF v_tiene_movimientos > 0 THEN
        SET p_mensaje = 'No se puede eliminar: tiene movimientos asociados';
    ELSE
        UPDATE proveedores SET deleted_at = NOW() WHERE id_proveedor = p_id_prov;
        SET p_mensaje = 'Proveedor eliminado correctamente';
    END IF;
END //

-- NUEVO SP 5: Obtener precio sugerido
CREATE PROCEDURE sp_sugerir_precio(
    IN p_id_proveedor INT,
    IN p_id_producto INT,
    OUT p_precio DECIMAL(10,2)
)
BEGIN
    SELECT precio_compra_sugerido
    INTO p_precio
    FROM producto_proveedores
    WHERE id_proveedor = p_id_proveedor
      AND id_producto = p_id_producto
      AND activo = TRUE
      AND deleted_at IS NULL
    LIMIT 1;
    
    -- Si no existe, devolver 0
    IF p_precio IS NULL THEN
        SET p_precio = 0.00;
    END IF;
END //

DELIMITER ;

-- ==========================================================
-- 11. FUNCIONES ÚTILES
-- ==========================================================

DELIMITER //

-- Función para obtener código de viaje completo
CREATE FUNCTION fn_codigo_viaje(p_id_viaje INT) 
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE v_codigo VARCHAR(30);
    SELECT CONCAT(r.codigo, '-V', v.numero_viaje)
    INTO v_codigo
    FROM viajes v
    JOIN requerimientos r ON v.id_requerimiento = r.id_requerimiento
    WHERE v.id_viaje = p_id_viaje;
    
    RETURN v_codigo;
END //

DELIMITER ;

-- ==========================================================
-- 12. DATOS INICIALES
-- ==========================================================

-- Usuario administrador por defecto
-- Contraseña: admin123 (Hash bcrypt con 12 rounds)
INSERT INTO usuarios (username, password_hash, nombre_completo, rol, activo)
VALUES ('admin', '$2b$12$LQZQzq4Hw4YqZfJxvJJ1UO5bpP9P6hGX0R3dG0mJ7aHqR0vQ0YJ4W', 'Administrador del Sistema', 'ADMIN', TRUE);

-- ==========================================================
-- FIN DEL SCRIPT MEJORADO
-- ==========================================================

/*
MEJORAS IMPLEMENTADAS:

✅ 1. Índices optimizados para consultas frecuentes
✅ 2. Vistas estratégicas para reportes comunes
✅ 3. Soft deletes en todas las tablas maestras
✅ 4. Auditoría mejorada con valores antes/después
✅ 5. Constraint de stock positivo
✅ 6. Histórico de cambios de precios
✅ 7. Histórico de contraseñas
✅ 8. Procedimientos almacenados adicionales
✅ 9. Funciones útiles
✅ 10. Campos de seguridad en usuarios

PRÓXIMOS PASOS:
- Ejecutar este script en MySQL
- Ejecutar el script de inserciones (mederera_erp_inserciones.sql)
- Configurar Prisma para generar tipos
- Implementar backend siguiendo plan_mejorado.md
*/
