DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tbloptions;

DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tbloptions()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblOptions'
          AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE `tblOptions`
        ADD CONSTRAINT `PK_tblOptions` PRIMARY KEY (`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblOptions_question_id'
    ) THEN
        ALTER TABLE `tblOptions`
        ADD CONSTRAINT `FK_tblOptions_question_id`
        FOREIGN KEY (`question_id`) REFERENCES `tblQuestions`(`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblOptions_created_by'
    ) THEN
        ALTER TABLE `tblOptions`
        ADD CONSTRAINT `FK_tblOptions_created_by`
        FOREIGN KEY (`created_by`) REFERENCES `tblUsers`(`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblOptions_updated_by'
    ) THEN
        ALTER TABLE `tblOptions`
        ADD CONSTRAINT `FK_tblOptions_updated_by`
        FOREIGN KEY (`updated_by`) REFERENCES `tblUsers`(`id`);
    END IF;
END$$

DELIMITER ;

CALL usp_tmp_add_constraints_in_tbloptions();
DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tbloptions;
