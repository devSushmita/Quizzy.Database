DROP PROCEDURE IF EXISTS usp_register_user;

DELIMITER $$

CREATE PROCEDURE usp_register_user(
    IN p_firstname VARCHAR(128),
    IN p_lastname VARCHAR(128),
    IN p_role_id INT,
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(64),
    OUT p_user_id INT
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_register_user';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT DEFAULT 'N/A';
    DECLARE l_message TEXT;
    SET p_id = -1;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET l_params = CONCAT(
            'p_firstname=', p_firstname, ', ',
            'p_lastname=', p_lastname, ', ',
            'p_email=', p_email, ', ',
            'p_password=**********, ',
            'p_role_id=', p_role_id
        );
        
        GET DIAGNOSTICS CONDITION 1
            l_sqlstate = RETURNED_SQLSTATE,
            l_error_code = MYSQL_ERRNO;

        CALL usp_log_error(
            l_storedprocedure_name,
            l_error_code,
            l_sqlstate,
            l_params,
            l_message
        );
    END;
    
    START TRANSACTION;
    
    INSERT INTO tblUsers (
        firstname,
        lastname,
        role_id,
        email,
        `password`
    )
    VALUES (
        p_firstname,
        p_lastname,
        p_role_id,
        p_email,
        p_password
    );
    
    SET p_user_id = LAST_INSERT_ID();
    COMMIT;
END $$

DELIMITER ;
