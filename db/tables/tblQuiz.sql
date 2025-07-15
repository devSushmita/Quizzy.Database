CREATE TABLE IF NOT EXISTS `tblQuiz` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(256) NOT NULL,
    `topic_id` INT NOT NULL,
    `void` BOOLEAN NOT NULL,
    `duration` INT NULL,
    `total_questions` INT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL,
    `created_by` INT NOT NULL,
    `updated_by` INT NULL
);
