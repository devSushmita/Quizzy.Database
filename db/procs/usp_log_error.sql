DROP PROCEDURE IF EXISTS usp_log_error;

DELIMITER $$

CREATE PROCEDURE usp_log_error (
    IN p_procedure_name VARCHAR(256),
    IN p_error_code INT,
    IN p_sqlstate_code CHAR(5),
    IN p_input_params TEXT,
    IN p_message TEXT
)
BEGIN
    DECLARE l_custom_message TEXT;

    CASE p_error_code
        WHEN 1062 THEN SET l_custom_message = 'Duplicate entry (violates UNIQUE constraint)';
        WHEN 1146 THEN SET l_custom_message = 'Table does not exist';
        WHEN 1054 THEN SET l_custom_message = 'Unknown column in field list';
        WHEN 1048 THEN SET l_custom_message = 'Column cannot be null';
        WHEN 1366 THEN SET l_custom_message = 'Incorrect string value';
        WHEN 1406 THEN SET l_custom_message = 'Data too long for column';
        WHEN 1451 THEN SET l_custom_message = 'Cannot delete or update parent row: foreign key constraint fails';
        WHEN 1452 THEN SET l_custom_message = 'Cannot add or update child row: foreign key constraint fails';
        ELSE SET l_custom_message = 'Unknown error';
    END CASE;

    INSERT INTO tblErrorLogs (
        procedure_name,
        error_code,
        sqlstate_code,
        params,
        `message`
    )
    VALUES (
        p_procedure_name,
        p_error_code,
        p_sqlstate_code,
        p_input_params,
        COALESCE(p_message, l_custom_message)
    );
END$$

DELIMITER ;
