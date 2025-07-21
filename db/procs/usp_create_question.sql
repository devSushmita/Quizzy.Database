DROP PROCEDURE IF EXISTS usp_create_question;

DELIMITER $$

CREATE PROCEDURE usp_create_question (
    IN p_title VARCHAR(512),
    IN p_level TINYINT,
    IN p_marks INT,
    IN p_topic_id INT,
    IN p_option1 VARCHAR(512),
    IN p_option2 VARCHAR(512),
    IN p_option3 VARCHAR(512),
    IN p_option4 VARCHAR(512),
    IN p_correct_option TINYINT
    IN p_created_by INT
)
BEGIN
    DECLARE l_easy_level TINYINT DEFAULT 1;
    DECLARE l_medium_level TINYINT DEFAULT 2;
    DECLARE l_hard_level TINYINT DEFAULT 3;
    DECLARE l_question_id INT;
    DECLARE l_answer_id INT;
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_create_question';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        
        SET l_params = CONCAT(
            'p_title=', p_title, ', ',
            'p_level=', p_level, ', ',
            'p_marks=', p_marks, ', ',
            'p_topic_id=', p_topic_id, ', ',
            'p_option1=', p_option1, ', ',
            'p_option2=', p_option2, ', ',
            'p_option3=', p_option3, ', ',
            'p_option4=', p_option4, ', ',
            'p_correct_option=', p_correct_option, ', '
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
        IF p_marks <= 0 THEN
            SET l_message = 'p_marks should be positive';
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = l_message;
        END IF;

        IF p_level NOT IN (l_easy_level, l_medium_level, l_hard_level) THEN
            SET l_message = 'p_level should be in 1 (easy), 2 (medium), 3 (hard)';
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = l_message;
        END IF;

        IF p_correct_option NOT BETWEEN 1 AND 4 THEN
            SET l_message = 'p_correct_option must be between 1 and 4';
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = l_message;
        END IF;

        INSERT INTO tblQuestions (
            title,
            `level`,
            marks,
            topic_id,
            created_by
        )
        VALUES (
            p_title,
            p_level,
            p_marks,
            p_topic_id,
            p_created_by
        );

        SET l_question_id = LAST_INSERT_ID();

        INSERT INTO tblOptions (
            question_id,
            `value`,
            created_by)
        VALUES
            (l_question_id, p_option1, p_created_by),
            (l_question_id, p_option2, p_created_by),
            (l_question_id, p_option3, p_created_by),
            (l_question_id, p_option4, p_created_by);

        SET l_answer_id = LAST_INSERT_ID() - 4 + p_correct_option;

        UPDATE tblQuestions
        SET answer_id = l_answer_id
        WHERE id = l_question_id;

        COMMIT;
    ELSE
        SET l_message = 'User is not authorized to create question';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = l_message;
    END IF;
END$$

DELIMITER ;
