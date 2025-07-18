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
    DECLARE l_sqlstate CHAR(5) DEFAULT 'HY000';
    DECLARE l_error_code INT DEFAULT 9999;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE l_temp_table_name VARCHAR(64) DEFAULT NULL;

    -- Error Handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        -- Drop temp table if exists
        IF l_temp_table_name IS NOT NULL THEN
            SET @sql_drop_tmp = CONCAT('DROP TEMPORARY TABLE IF EXISTS `', l_temp_table_name, '`');
            PREPARE stmt_drop_tmp FROM @sql_drop_tmp;
            EXECUTE stmt_drop_tmp;
            DEALLOCATE PREPARE stmt_drop_tmp;
        END IF;

        SET l_params = CONCAT('p_user_id=', p_user_id, ', p_quiz_id=', p_quiz_id);

        -- Log the error
        CALL usp_log_error(
            l_storedprocedure_name,
            l_error_code,
            l_sqlstate,
            l_params,
            l_message
        );
    END;

    START TRANSACTION;

    -- Fetch quiz details
    SELECT name, topic_id, duration, total_questions
    INTO l_quiz_name, l_quiz_topic_id, l_quiz_duration, l_quiz_total_questions
    FROM tblQuiz
    WHERE id = p_quiz_id AND void = l_is_voided;

    -- If quiz not found
    IF l_quiz_name IS NULL THEN
        SET l_message = 'No quiz found with the given p_quiz_id';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_message;
    ELSE
        -- Check if enough questions exist
        SELECT COUNT(id) INTO l_available_questions
        FROM tblQuestions
        WHERE topic_id = l_quiz_topic_id;

        IF l_available_questions < l_quiz_total_questions THEN
            SET l_message = 'Sufficient questions for the quiz are not available';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_message;
        ELSE
            -- Create dynamic temp table for selected questions
            SET l_temp_table_name = CONCAT('tmpQ_', DATE_FORMAT(UTC_TIMESTAMP(6), '%Y%m%d%H%i%s%f'));

            SET @sql_create_tmp = CONCAT(
                'CREATE TEMPORARY TABLE `', l_temp_table_name, '` AS ',
                'SELECT id, title, level, marks, answer_id ',
                'FROM tblQuestions ',
                'WHERE topic_id = ', l_quiz_topic_id, ' ',
                'ORDER BY RAND() ',
                'LIMIT ', l_quiz_total_questions
            );
            PREPARE stmt_create_tmp FROM @sql_create_tmp;
            EXECUTE stmt_create_tmp;
            DEALLOCATE PREPARE stmt_create_tmp;

            -- Prepare JSON configuration
            SET @json = NULL;
            SET @sql_json = CONCAT(
                'SELECT JSON_ARRAYAGG(JSON_OBJECT(',
                    '\'id\', id, ',
                    '\'title\', title, ',
                    '\'level\', level, ',
                    '\'marks\', marks, ',
                    '\'answer_id\', answer_id',
                ')) INTO @json FROM `', l_temp_table_name, '`'
            );
            PREPARE stmt_json FROM @sql_json;
            EXECUTE stmt_json;
            DEALLOCATE PREPARE stmt_json;
            SET l_quiz_configuration = @json;

            -- Calculate total marks
            SET @total_marks = 0;
            SET @sql_total = CONCAT(
                'SELECT SUM(marks) INTO @total_marks FROM `', l_temp_table_name, '`'
            );
            PREPARE stmt_total FROM @sql_total;
            EXECUTE stmt_total;
            DEALLOCATE PREPARE stmt_total;
            SET l_total_marks = IFNULL(@total_marks, 0);

            -- Get last attempt
            SELECT attempt
            INTO l_latest_attempt
            FROM tblSubmissions
            WHERE user_id = p_user_id
              AND quiz_id = p_quiz_id
              AND status IN (l_submitted, l_auto_submitted)
            ORDER BY attempt DESC
            LIMIT 1;

            SET l_last_attempt = COALESCE(l_latest_attempt, 0);

            -- Insert into submissions
            INSERT INTO tblSubmissions (
                user_id, quiz_id, attempt, configuration, started_at, status, total_marks
            ) VALUES (
                p_user_id, p_quiz_id, l_last_attempt + 1, l_quiz_configuration, UTC_TIMESTAMP(), l_in_progress, l_total_marks
            );

            -- Drop temp table
            SET @sql_drop_tmp = CONCAT('DROP TEMPORARY TABLE IF EXISTS `', l_temp_table_name, '`');
            PREPARE stmt_drop_tmp2 FROM @sql_drop_tmp;
            EXECUTE stmt_drop_tmp2;
            DEALLOCATE PREPARE stmt_drop_tmp2;

            COMMIT;
        END IF;
    END IF;

END$$
DELIMITER ;
