-- Check and add PRIMARY KEY if not exists
DO
BEGIN
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
END;

-- Check and add UNIQUE constraint on name if not exists
DO
BEGIN
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
END;
