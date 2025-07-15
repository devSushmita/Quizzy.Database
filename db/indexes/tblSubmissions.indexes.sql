DELIMITER $$

CREATE PROCEDURE usp_tmp_add_indexes_in_tblsubmissions()
BEGIN
    -- Add INDEX on quiz_id if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'tblSubmissions'
          AND index_name = 'idx_tblSubmissions_quiz_id'
    ) THEN
        ALTER TABLE `tblSubmissions`
        ADD INDEX `idx_tblSubmissions_quiz_id` (`quiz_id`);
    END IF;

    -- Add INDEX on user_id if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'tblSubmissions'
          AND index_name = 'idx_tblSubmissions_user_id'
    ) THEN
        ALTER TABLE `tblSubmissions`
        ADD INDEX `idx_tblSubmissions_user_id` (`user_id`);
    END IF;
END$$

DELIMITER ;

-- Call the procedure
CALL usp_tmp_add_indexes_in_tblsubmissions();

-- Optionally drop it after use
DROP PROCEDURE usp_tmp_add_indexes_in_tblsubmissions;
