DROP PROCEDURE IF EXISTS usp_start_quiz;
DELIMITER $$

CREATE PROCEDURE usp_start_quiz (
    IN p_user_id INT,
    IN p_quiz_id INT
)
BEGIN
    DECLARE l_is_voided BOOLEAN DEFAULT FALSE;
    DECLARE l_quiz_name VARCHAR(256);
    DECLARE l_quiz_topic_id INT;
    DECLARE l_quiz_duration INT;
    DECLARE l_quiz_total_questions INT;
    DECLARE l_quiz_configuration JSON;
    DECLARE l_available_questions INT DEFAULT 0;
    DECLARE l_in_progress INT DEFAULT 1;
    DECLARE l_submitted INT DEFAULT 2;
    DECLARE l_auto_submitted INT DEFAULT 3;
    DECLARE l_latest_attempt INT DEFAULT 0;
    DECLARE l_last_attempt INT DEFAULT 0;
    DECLARE l_total_marks INT DEFAULT 0;
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_start_quiz';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS tblTempQuestions;
        SET l_params = CONCAT('p_user_id=', p_user_id, ', ', 'p_quiz_id=', p_quiz_id);

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

    -- Get quiz details
    SELECT 
        name,
        topic_id,
        duration,
        total_questions
    INTO
        l_quiz_name,
        l_quiz_topic_id,
        l_quiz_duration,
        l_quiz_total_questions
    FROM tblQuiz
    WHERE id = p_quiz_id
      AND void = l_is_voided;

    -- Quiz not found
    IF l_quiz_name IS NULL THEN
        SET l_message = 'No quiz found with the given p_quiz_id';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = l_message;
    ELSE
        -- Check question availability
        SELECT COUNT(id)
        INTO l_available_questions
        FROM tblQuestions
        WHERE topic_id = l_quiz_topic_id;

		-- Sufficient questions are not available
        IF l_available_questions < l_quiz_total_questions THEN
            SET l_message = 'Sufficient questions for the quiz are not available';
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = l_message;
        ELSE
            -- Select random questions
            CREATE TEMPORARY TABLE tblTempQuestions AS
            SELECT * FROM (
                SELECT id, title, level, marks
                FROM tblQuestions
                WHERE topic_id = l_quiz_topic_id
                ORDER BY RAND()
                LIMIT l_quiz_total_questions
            ) AS sub;

            -- Convert to JSON
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', id,
                    'title', title,
                    'level', level,
                    'marks', marks
                )
            )
            INTO l_quiz_configuration
            FROM tblTempQuestions;

            -- Get latest attempt number
            SELECT attempt
            INTO l_latest_attempt
            FROM tblSubmissions
            WHERE user_id = p_user_id
              AND quiz_id = p_quiz_id
              AND status IN (l_submitted, l_auto_submitted)
            ORDER BY attempt DESC
            LIMIT 1;

            -- Total marks from selected questions
            SELECT SUM(marks)
            INTO l_total_marks
            FROM tblTempQuestions;

            -- Insert submission
            INSERT INTO tblSubmissions (
                user_id,
                quiz_id,
                attempt,
                configuration,
                started_at,
                status,
                total_marks
            )
            VALUES (
                p_user_id,
                p_quiz_id,
                l_last_attempt + 1,
                l_quiz_configuration,
                UTC_TIMESTAMP(),
                l_in_progress,
                l_total_marks
            );

            -- Cleanup
            DROP TEMPORARY TABLE IF EXISTS tblTempQuestions;

            COMMIT;
        END IF;
    END IF;

END$$

DELIMITER ;
