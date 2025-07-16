DROP PROCEDURE IF EXISTS usp_create_quiz;

DELIMITER $$

CREATE PROCEDURE usp_create_quiz (
    IN p_user_id INT,
    IN p_name VARCHAR(512),
    IN p_topic_id INT,
    IN p_duration INT,
    IN p_total_questions INT
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_create_quiz';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET l_params = CONCAT(
            'p_user_id=', p_user_id, ', ',
            'p_name=', p_name, ', ',
            'p_topic_id=', p_topic_id, ', ',
            'p_duration=', p_duration, ', ',
            'p_total_questions=', p_total_questions
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

    IF ufn_is_admin(p_user_id) THEN
        INSERT INTO tblQuiz (`name`, topic_id, duration, total_questions, created_by)
        VALUES (p_name, p_topic_id, p_duration, p_total_questions, p_user_id);
        COMMIT;
    ELSE
        SET l_message = 'User is not authorized to create quiz';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = l_message;
    END IF;
END$$

DELIMITER ;
