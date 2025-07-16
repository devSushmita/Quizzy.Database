DROP PROCEDURE IF EXISTS usp_get_history;

DELIMITER $$

CREATE PROCEDURE usp_get_history (
    IN p_user_id INT
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_get_history';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET l_params = CONCAT('p_user_id=', p_user_id);

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

    IF NOT ufn_is_admin(p_user_id) THEN
        SELECT
            id,
            quiz_id,
            attempt,
            response,
            `status`,
            score,
            total_marks
        FROM tblSubmissions
        ORDER BY submitted_at DESC;
    ELSE
        SET l_message = 'Invalid action for the user';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = l_message;
    END IF;
END$$

DELIMITER ;
