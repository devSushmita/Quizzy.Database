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
    DECLARE l_last_attempt INT DEFAULT 0;
    DECLARE l_total_marks INT DEFAULT 0;
    DECLARE l_new_submission_id BIGINT UNSIGNED DEFAULT NULL;

    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_start_quiz';
    DECLARE l_sqlstate CHAR(5) DEFAULT 'HY000';
    DECLARE l_error_code INT DEFAULT 9999;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET l_params = CONCAT('p_user_id=', p_user_id, ', p_quiz_id=', p_quiz_id);

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

    SELECT name, topic_id, duration, total_questions
      INTO l_quiz_name, l_quiz_topic_id, l_quiz_duration, l_quiz_total_questions
      FROM tblQuiz
     WHERE id = p_quiz_id
       AND void = l_is_voided
     LIMIT 1;

    IF l_quiz_name IS NULL THEN
        SET l_message = 'No quiz found with the given p_quiz_id.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_message;
    END IF;

    SELECT COUNT(id) INTO l_available_questions
      FROM tblQuestions
     WHERE topic_id = l_quiz_topic_id;

    IF l_available_questions < l_quiz_total_questions THEN
        SET l_message = CONCAT(
            'Sufficient questions for the quiz are not available. Required=',
            l_quiz_total_questions, ', Found=', l_available_questions
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_message;
    END IF;

    WITH RandomQuestions AS (
        SELECT id, title, level, marks, answer_id
          FROM tblQuestions
         WHERE topic_id = l_quiz_topic_id
         ORDER BY RAND()
         LIMIT l_quiz_total_questions
    )
    SELECT JSON_ARRAYAGG(
               JSON_OBJECT(
                   'id', id,
                   'title', title,
                   'level', level,
                   'marks', marks,
                   'answer_id', answer_id
               )
           ) AS quiz_configuration,
           COALESCE(SUM(marks), 0) AS total_marks
      INTO l_quiz_configuration, l_total_marks
      FROM RandomQuestions;

    SELECT COALESCE(MAX(attempt), 0)
      INTO l_last_attempt
      FROM tblSubmissions
     WHERE user_id = p_user_id
       AND quiz_id = p_quiz_id
       AND status IN (l_submitted, l_auto_submitted);

    INSERT INTO tblSubmissions (
        user_id,
        quiz_id,
        attempt,
        configuration,
        started_at,
        status,
        total_marks
    ) VALUES (
        p_user_id,
        p_quiz_id,
        l_last_attempt + 1,
        l_quiz_configuration,
        UTC_TIMESTAMP(),
        l_in_progress,
        l_total_marks
    );

    SET l_new_submission_id = LAST_INSERT_ID();

    COMMIT;

    -- Select submission details
    SELECT id,
        user_id,
        quiz_id,
        attempt,
        status,
        score,
        total_marks,
        started_at,
        submitted_at,
        updated_at
    FROM tblSubmissions
    WHERE id = l_new_submission_id;

END$$
DELIMITER ;
