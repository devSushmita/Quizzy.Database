DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblerrorlogs;

DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblerrorlogs()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblErrorLogs'
          AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE `tblErrorLogs`
        ADD CONSTRAINT `PK_tblErrorLogs` PRIMARY KEY (`id`);
    END IF;
END$$

DELIMITER ;

CALL usp_tmp_add_constraints_in_tblerrorlogs();
DROP PROCEDURE IF EXISTS usp_tmp_add_constraints_in_tblerrorlogs;
