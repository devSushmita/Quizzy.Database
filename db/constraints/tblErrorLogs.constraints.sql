DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tblerrorlogs()
BEGIN
    -- Add PRIMARY KEY on id if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblErrorLogs'
          AND constraint_name = 'PK_tblErrorLogs'
    ) THEN
        ALTER TABLE `tblErrorLogs`
        ADD CONSTRAINT `PK_tblErrorLogs` PRIMARY KEY (`id`);
    END IF;
END$$

DELIMITER ;

-- Call the procedure
CALL usp_tmp_add_constraints_in_tblerrorlogs();

-- Drop the procedure if it's temporary
DROP PROCEDURE usp_tmp_add_constraints_in_tblerrorlogs;
