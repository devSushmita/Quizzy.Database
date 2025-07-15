DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblroles()
BEGIN
    -- Check and add PRIMARY KEY if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = DATABASE()
          AND TABLE_NAME = 'tblRoles'
          AND CONSTRAINT_NAME = 'PK_tblRoles'
    ) THEN
        ALTER TABLE `tblRoles`
        ADD CONSTRAINT `PK_tblRoles` PRIMARY KEY (`id`);
    END IF;

    -- Check and add UNIQUE constraint on name if not exists
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

-- Call the procedure
CALL usp_tmp_add_constraints_in_tblroles();

-- Drop it if it's a one-time use
DROP PROCEDURE usp_tmp_add_constraints_in_tblroles;
