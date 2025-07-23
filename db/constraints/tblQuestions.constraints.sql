DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblquestions;

DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblquestions()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblQuestions'
          AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE `tblQuestions`
        ADD CONSTRAINT `PK_tblQuestions` PRIMARY KEY (`id`);
    END IF;

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

CALL usp_tmp_add_constraints_in_tblquestions();
DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblquestions;
