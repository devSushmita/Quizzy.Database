DELIMITER $$

CREATE PROCEDURE usp_tmp_add_indexes_in_tbloptions()
BEGIN
    -- Add INDEX on question_id if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'tblOptions'
          AND index_name = 'idx_tblOptions_question_id'
    ) THEN
        ALTER TABLE `tblOptions`
        ADD INDEX `idx_tblOptions_question_id` (`question_id`);
    END IF;
END$$

DELIMITER ;

-- Call the procedure
CALL usp_tmp_add_indexes_in_tbloptions();

-- Drop the procedure if it's temporary
DROP PROCEDURE usp_tmp_add_indexes_in_tbloptions;
