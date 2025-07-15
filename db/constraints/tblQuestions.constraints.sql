DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblquestions()
BEGIN
    -- Add PRIMARY KEY if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblQuestions'
          AND constraint_name = 'PK_tblQuestions'
    ) THEN
        ALTER TABLE `tblQuestions`
        ADD CONSTRAINT `PK_tblQuestions` PRIMARY KEY (`id`);
    END IF;

    -- Add FOREIGN KEY: topic_id → tblTopics(id)
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblQuestions_topic_id'
    ) THEN
        ALTER TABLE `tblQuestions`
        ADD CONSTRAINT `FK_tblQuestions_topic_id`
        FOREIGN KEY (`topic_id`) REFERENCES `tblTopics`(`id`);
    END IF;

    -- Add FOREIGN KEY: created_by → tblUsers(id)
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblQuestions_created_by'
    ) THEN
        ALTER TABLE `tblQuestions`
        ADD CONSTRAINT `FK_tblQuestions_created_by`
        FOREIGN KEY (`created_by`) REFERENCES `tblUsers`(`id`);
    END IF;

    -- Add FOREIGN KEY: updated_by → tblUsers(id)
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblQuestions_updated_by'
    ) THEN
        ALTER TABLE `tblQuestions`
        ADD CONSTRAINT `FK_tblQuestions_updated_by`
        FOREIGN KEY (`updated_by`) REFERENCES `tblUsers`(`id`);
    END IF;
END$$

DELIMITER ;

-- Call the procedure
CALL usp_tmp_add_constraints_in_tblquestions();

-- Drop procedure after execution
DROP PROCEDURE usp_tmp_add_constraints_in_tblquestions;
