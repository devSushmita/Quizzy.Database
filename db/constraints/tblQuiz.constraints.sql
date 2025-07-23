DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblquiz;

DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblquiz()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblQuiz'
          AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE `tblQuiz`
        ADD CONSTRAINT `PK_tblQuiz` PRIMARY KEY (`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblQuiz_topic_id'
    ) THEN
        ALTER TABLE `tblQuiz`
        ADD CONSTRAINT `FK_tblQuiz_topic_id`
        FOREIGN KEY (`topic_id`) REFERENCES `tblTopics`(`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblQuiz_created_by'
    ) THEN
        ALTER TABLE `tblQuiz`
        ADD CONSTRAINT `FK_tblQuiz_created_by`
        FOREIGN KEY (`created_by`) REFERENCES `tblUsers`(`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblQuiz_updated_by'
    ) THEN
        ALTER TABLE `tblQuiz`
        ADD CONSTRAINT `FK_tblQuiz_updated_by`
        FOREIGN KEY (`updated_by`) REFERENCES `tblUsers`(`id`);
    END IF;
END$$

DELIMITER ;

CALL usp_tmp_add_constraints_in_tblquiz();
DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblquiz;
