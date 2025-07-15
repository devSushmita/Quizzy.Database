CREATE TABLE IF NOT EXISTS `tblTopics` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(64) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL,
    `created_by` INT NOT NULL,
    `updated_by` INT NULL
);
