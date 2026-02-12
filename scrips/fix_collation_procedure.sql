-- =============================================================================
-- SCRIPT DE CORRECCIÓN DE COLLATION EN STORED PROCEDURE
-- =============================================================================
-- Este script corrige el error "Illegal mix of collations" en el SP de
-- generación de código de requerimientos.
-- =============================================================================

USE db_maderera_erp;

DROP PROCEDURE IF EXISTS sp_generar_codigo_requerimiento;

DELIMITER //

CREATE PROCEDURE sp_generar_codigo_requerimiento(OUT p_codigo VARCHAR(20))
BEGIN
    DECLARE v_anio CHAR(4);
    DECLARE v_ultimo INT DEFAULT 0;
    DECLARE v_prefix VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    
    SET v_anio = CAST(YEAR(CURRENT_DATE()) AS CHAR(4));
    
    -- Forzamos la collation del string generado para que coincida con la columna 'codigo'
    -- que se creó como utf8mb4_unicode_ci en el script original.
    SET v_prefix = CONCAT('REQ-', v_anio, '-%');
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(codigo, 10) AS UNSIGNED)), 0) + 1
    INTO v_ultimo
    FROM requerimientos
    WHERE codigo LIKE v_prefix COLLATE utf8mb4_unicode_ci;
    
    SET p_codigo = CONCAT('REQ-', v_anio, '-', LPAD(v_ultimo, 4, '0'));
END //

DELIMITER ;

-- Verificación rápida (Opcional, si falla aquí es que sigue mal configurado)
-- CALL sp_generar_codigo_requerimiento(@test_code);
-- SELECT @test_code;
