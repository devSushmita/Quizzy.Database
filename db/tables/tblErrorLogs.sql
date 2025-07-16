CREATE TABLE IF NOT EXISTS `tblErrorLogs` (
    `id` INT AUTO_INCREMENT,
    `procedure_name` VARCHAR(256),
    `params` TEXT,
    `error_code` INT,
    `sqlstate_code` CHAR(5),
    `occured_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `message` TEXT
);
