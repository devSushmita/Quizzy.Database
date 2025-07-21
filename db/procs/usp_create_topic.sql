DROP PROCEDURE IF EXISTS usp_create_topic;

DELIMITER $$

CREATE PROCEDURE usp_create_topic (
    IN p_name VARCHAR(512),
    IN p_created_by INT,
    OUT p_topic_id INT
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_create_topic';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET l_params = CONCAT(
            'p_name=', p_name, ', ',
            'p_created_by=', p_created_by
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

    START TRANSACTION;

    IF ufn_is_admin(p_created_by) THEN
        INSERT INTO tblTopics (
            `name`,
            created_by)
        VALUES (
            p_name,
            p_created_by
        );

        SET p_topic_id = LAST_INSERT_ID();
        COMMIT;
    ELSE
        SET l_message = 'User is not authorized to create topic';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = l_message;
    END IF;
END$$

DELIMITER ;
