DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblusers;

DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblusers()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblUsers'
          AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE `tblUsers`
        ADD CONSTRAINT `PK_tblUsers` PRIMARY KEY (`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblUsers'
          AND constraint_name = 'UQ_tblUsers_email'
    ) THEN
        ALTER TABLE `tblUsers`
        ADD CONSTRAINT `UQ_tblUsers_email` UNIQUE (`email`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblUsers_role_id'
    ) THEN
        ALTER TABLE `tblUsers`
        ADD CONSTRAINT `FK_tblUsers_role_id` FOREIGN KEY (`role_id`) REFERENCES `tblRoles`(`id`);
    END IF;
END$$

DELIMITER ;

CALL usp_tmp_add_constraints_in_tblusers();
DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblusers;
