DELIMITER $$

DROP EVENT IF EXISTS ev_auto_timeout_submissions $$
CREATE EVENT ev_auto_timeout_submissions
    ON SCHEDULE EVERY 2 MINUTE
    STARTS CURRENT_TIMESTAMP
    ON COMPLETION PRESERVE
    ENABLE
    DO
    BEGIN
		DECLARE l_in_progress TINYINT DEFAULT 1;
        DECLARE l_expired TINYINT DEFAULT 4;
        
        UPDATE tblSubmissions AS s
        INNER JOIN tblQuiz AS q ON q.id = s.quiz_id
        SET
            s.status = l_expired,
            s.updated_at = UTC_TIMESTAMP()
        WHERE
            s.status = l_in_progress
            AND s.started_at IS NOT NULL
            AND q.duration > 0
            AND s.started_at + INTERVAL q.duration SECOND <= UTC_TIMESTAMP();
    END $$

DELIMITER ;
