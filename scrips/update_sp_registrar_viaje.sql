DELIMITER //

DROP PROCEDURE IF EXISTS sp_registrar_viaje//

CREATE PROCEDURE sp_registrar_viaje(
    IN p_id_req INT,
    IN p_placa VARCHAR(20),
    IN p_conductor VARCHAR(100),
    IN p_numero_vale VARCHAR(50), -- New parameter
    IN p_usuario VARCHAR(80),
    IN p_fecha_ingreso DATETIME,
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
    
    -- Insertar viaje con la fecha proporcionada o NOW() si es NULL
    INSERT INTO viajes (id_requerimiento, numero_viaje, placa_vehiculo, conductor, numero_vale, created_by, fecha_ingreso)
    VALUES (p_id_req, v_numero_viaje, p_placa, p_conductor, p_numero_vale, p_usuario, COALESCE(p_fecha_ingreso, NOW()));
    
    SET p_id_viaje = LAST_INSERT_ID();
    
    COMMIT;
END //

DELIMITER ;
