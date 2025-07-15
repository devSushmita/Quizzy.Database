CREATE TABLE IF NOT EXISTS `tblQuestions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(1024) NOT NULL,
    `level` TINYINT NOT NULL,
    `marks` INT NOT NULL DEFAULT 1,
    `answer_id` INT NULL,
    `topic_id` INT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL,
    `created_by` INT NOT NULL,
    `updated_by` INT NULL
);
