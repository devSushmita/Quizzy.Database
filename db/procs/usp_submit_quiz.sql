DROP PROCEDURE IF EXISTS usp_submit_quiz;
DELIMITER $$

CREATE PROCEDURE usp_submit_quiz (
    IN p_user_id       INT,
    IN p_submission_id INT,
    IN p_status        TINYINT,
    IN p_response      JSON
)
BEGIN
    DECLARE l_in_progress     TINYINT DEFAULT 1;
    DECLARE l_submitted       TINYINT DEFAULT 2;
    DECLARE l_auto_submitted  TINYINT DEFAULT 3;

    DECLARE l_submission_user INT;
    DECLARE l_submission_quiz INT;
    DECLARE l_submission_status TINYINT;
    DECLARE l_total_marks INT;
    DECLARE l_score INT DEFAULT 0;
    DECLARE l_now_utc TIMESTAMP;

    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_submit_quiz';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET l_params = CONCAT('p_user_id=',p_user_id,
                              ', p_submission_id=',p_submission_id,
                              ', p_status=',p_status,
                              ', p_response=',p_response);
        CALL usp_log_error(
			l_storedprocedure_name,
			l_error_code,
            l_sqlstate,
            l_params,
            l_message);
    END;

    START TRANSACTION;

    -- Check the status of the submission
    IF p_status NOT IN (l_submitted, l_auto_submitted) THEN
        SET l_message = 'Invalid p_status; must be 2 (submitted) or 3 (auto-submitted).';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_message;
    END IF;

	-- Get submission details
	SELECT user_id,
        quiz_id,
        status,
        total_marks
	INTO l_submission_user,
        l_submission_quiz,
        l_submission_status,
        l_total_marks
	FROM tblSubmissions
	WHERE id = p_submission_id
    AND user_id = p_user_id
    AND status = p_status;

    -- No valid submission found
    IF l_submission_user IS NULL THEN
        SET l_message = 'Submission not found.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_message;
    END IF;

    SET @score := 0;

    -- Create CTE for configuration and response
    WITH cfg AS (
        SELECT jt_cfg.q_id,
            jt_cfg.marks,
            jt_cfg.correct_answer_id
        FROM tblSubmissions s
        CROSS JOIN JSON_TABLE(s.configuration, '$[*]' COLUMNS (
            q_id INT PATH '$.id',
            marks INT PATH '$.marks',
            correct_answer_id INT PATH '$.answer_id'
        )) AS jt_cfg
        WHERE s.id = p_submission_id
    ),
    resp AS (
        SELECT jt_resp.q_id,
            jt_resp.ans_id
        FROM JSON_TABLE(p_response, '$[*]' COLUMNS (
            q_id INT PATH '$.question_id',
            ans_id INT PATH '$.answer_id'
        )) AS jt_resp
    )

    -- Calculate total score
    SELECT SUM(
        CASE
            WHEN resp.ans_id IS NOT NULL
            AND resp.ans_id = cfg.correct_answer_id
            THEN cfg.marks ELSE 0 END)
    INTO @score
    FROM cfg
    LEFT JOIN resp ON resp.q_id = cfg.q_id;

    SET l_score = IFNULL(@score, 0);
    SET l_now_utc = UTC_TIMESTAMP();

    -- Update submissions table
    UPDATE tblSubmissions
       SET response     = p_response,
           status       = p_status,
           submitted_at = l_now_utc,
           updated_at   = l_now_utc,
           score        = l_score
    WHERE id = p_submission_id;

    COMMIT;

    -- Select submission details
    SELECT id,
		user_id,
        quiz_id,
        attempt,
        status,
        score,
        total_marks,
        submitted_at,
        updated_at
    FROM tblSubmissions
    WHERE id = p_submission_id;
END$$
DELIMITER ;
