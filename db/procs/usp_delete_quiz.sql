DROP PROCEDURE IF EXISTS usp_delete_quiz;

DELIMITER $$

CREATE PROCEDURE usp_delete_quiz(
    IN p_quiz_id INT,
    IN p_deleted_by INT
)
BEGIN
    DECLARE l_deleted BOOLEAN DEFAULT 1;
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_delete_quiz';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET l_params = CONCAT(
            'p_deleted_by=', p_deleted_by, ', ',
            'p_quiz_id=', p_quiz_id
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

    IF ufn_is_admin(p_deleted_by) THEN
        UPDATE tblQuiz
        SET void = l_deleted,
            updated_at = UTC_TIMESTAMP(),
            updated_by = p_deleted_by
        WHERE id = p_quiz_id;
        COMMIT;
    ELSE
        SET l_message = 'User is not authorized to delete quiz';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = l_message;
    END IF;
END$$

DELIMITER ;
