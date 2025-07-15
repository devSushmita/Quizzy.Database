DELIMITER $$

CREATE PROCEDURE usp_tmp_add_indexes_in_tblquestions()
BEGIN
    -- Add INDEX on topic_id if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'tblQuestions'
          AND index_name = 'idx_tblQuestions_topic_id'
    ) THEN
        ALTER TABLE `tblQuestions`
        ADD INDEX `idx_tblQuestions_topic_id` (`topic_id`);
    END IF;
END$$

DELIMITER ;

-- Call the procedure
CALL usp_tmp_add_indexes_in_tblquestions();

-- Drop the procedure after use (optional)
DROP PROCEDURE usp_tmp_add_indexes_in_tblquestions;
