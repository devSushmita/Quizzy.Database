DROP PROCEDURE IF EXISTS usp_get_history;

DELIMITER $$

CREATE PROCEDURE usp_get_history (
    IN p_user_id INT
)
BEGIN
    DECLARE l_submitted TINYINT DEFAULT 2;
    DECLARE l_auto_submitted TINYINT DEFAULT 3;
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

        RESIGNAL;
    END;

    SELECT
        id,
        quiz_id,
        attempt,
        configuration,
        response,
        `status`,
        score,
        total_marks,
        started_at,
        submitted_at
    FROM tblSubmissions
    WHERE user_id = p_user_id
    AND status IN (l_submitted, l_auto_submitted)
    ORDER BY submitted_at DESC;
END$$

DELIMITER ;
