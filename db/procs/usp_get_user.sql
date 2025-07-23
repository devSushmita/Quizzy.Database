DROP PROCEDURE IF EXISTS usp_get_user;

DELIMITER $$

CREATE PROCEDURE usp_get_user(
    IN p_id INT,
    IN p_email VARCHAR(255)
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_get_user';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET l_params = CONCAT_WS(', ',
            CONCAT('p_id=', p_id),
            CONCAT('p_email=', p_email)
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

        RESIGNAL;
    END;
    
    SELECT
        id,
        firstname,
        lastname,
        role_id,
        email,
        `password`,
        created_at,
        updated_at
    FROM tblUsers
    WHERE (
        (p_id IS NOT NULL
        AND id = p_id)
        OR (p_email IS NOT NULL
        AND email = p_email)
    );
END $$

DELIMITER ;
