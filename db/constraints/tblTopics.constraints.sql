DELIMITER $$

CREATE PROCEDURE usp_tmp_add_constraints_in_tbltopics()
BEGIN
    -- Add PRIMARY KEY if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_schema = DATABASE()
          AND table_name = 'tblTopics'
          AND constraint_name = 'PK_tblTopics'
    ) THEN
        ALTER TABLE `tblTopics`
        ADD CONSTRAINT `PK_tblTopics` PRIMARY KEY (`id`);
    END IF;

    -- Add FOREIGN KEY: created_by → tblUsers(id)
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblTopics_created_by'
    ) THEN
        ALTER TABLE `tblTopics`
        ADD CONSTRAINT `FK_tblTopics_created_by`
        FOREIGN KEY (`created_by`) REFERENCES `tblUsers`(`id`);
    END IF;

    -- Add FOREIGN KEY: updated_by → tblUsers(id)
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = DATABASE()
          AND constraint_name = 'FK_tblTopics_updated_by'
    ) THEN
        ALTER TABLE `tblTopics`
        ADD CONSTRAINT `FK_tblTopics_updated_by`
        FOREIGN KEY (`updated_by`) REFERENCES `tblUsers`(`id`);
    END IF;
END$$

DELIMITER ;

-- Execute the procedure
CALL usp_tmp_add_constraints_in_tbltopics();

-- Optionally drop it if it's one-time use
DROP PROCEDURE usp_tmp_add_constraints_in_tbltopics;
