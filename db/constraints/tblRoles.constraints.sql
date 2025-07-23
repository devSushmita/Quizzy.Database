DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblroles;

DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblroles()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = DATABASE()
          AND TABLE_NAME = 'tblRoles'
          AND CONSTRAINT_TYPE = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE `tblRoles`
        ADD CONSTRAINT `PK_tblRoles` PRIMARY KEY (`id`);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = DATABASE()
          AND TABLE_NAME = 'tblRoles'
          AND CONSTRAINT_NAME = 'UQ_tblRoles_name'
    ) THEN
        ALTER TABLE `tblRoles`
        ADD CONSTRAINT `UQ_tblRoles_name` UNIQUE (`name`);
    END IF;
END$$

DELIMITER ;

CALL usp_tmp_add_constraints_in_tblroles();
DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblroles;
