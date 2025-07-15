DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblsubmissions()
BEGIN
    -- Add PRIMARY KEY on id if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblSubmissions'
          AND constraint_name = 'PK_tblSubmissions'
    ) THEN
        ALTER TABLE `tblSubmissions`
        ADD CONSTRAINT `PK_tblSubmissions` PRIMARY KEY (`id`);
    END IF;

    -- Add FOREIGN KEY: user_id → tblUsers(id)
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

    -- Add FOREIGN KEY: quiz_id → tblQuiz(id)
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

-- Call the procedure
CALL usp_tmp_add_constraints_in_tblsubmissions();

-- Optionally drop it after use
DROP PROCEDURE usp_tmp_add_constraints_in_tblsubmissions;
