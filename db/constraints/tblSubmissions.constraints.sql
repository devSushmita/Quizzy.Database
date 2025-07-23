DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblsubmissions;

DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblsubmissions()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblSubmissions'
          AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE `tblSubmissions`
        ADD CONSTRAINT `PK_tblSubmissions` PRIMARY KEY (`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblSubmissions_user_id'
    ) THEN
        ALTER TABLE `tblSubmissions`
        ADD CONSTRAINT `FK_tblSubmissions_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `tblUsers`(`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblSubmissions_quiz_id'
    ) THEN
        ALTER TABLE `tblSubmissions`
        ADD CONSTRAINT `FK_tblSubmissions_quiz_id`
        FOREIGN KEY (`quiz_id`) REFERENCES `tblQuiz`(`id`);
    END IF;
END$$

DELIMITER ;

CALL usp_tmp_add_constraints_in_tblsubmissions();
DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblsubmissions;
