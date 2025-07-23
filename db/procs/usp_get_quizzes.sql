DROP PROCEDURE IF EXISTS usp_get_quizzes;

DELIMITER $$

CREATE PROCEDURE usp_get_quizzes (
    IN p_topic_id INT
)
BEGIN
    DECLARE l_is_deleted BOOLEAN DEFAULT FALSE;
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_get_quizzes';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET l_params = CONCAT('p_topic_id=', p_topic_id);

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

    SELECT
        id,
        name,
        topic_id,
        duration,
        total_questions,
        created_at,
        updated_at,
        created_by,
        updated_by
    FROM tblQuiz
    WHERE topic_id = p_topic_id
    AND void = l_is_deleted;
END$$

DELIMITER ;
