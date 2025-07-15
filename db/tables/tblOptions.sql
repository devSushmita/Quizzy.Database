CREATE TABLE IF NOT EXISTS `tblOptions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `question_id` INT NULL,
    `value` VARCHAR(512) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL,
    `created_by` INT NOT NULL,
    `updated_by` INT NULL
);
