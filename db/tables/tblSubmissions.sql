CREATE TABLE IF NOT EXISTS `tblSubmissions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `attempt` INT NOT NULL,
    `user_id` INT NOT NULL,
    `quiz_id` INT NOT NULL,
    `configuration` JSON NOT NULL,
    `response` JSON NULL,
    `started_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `submitted_at TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    `status` TINYINT NOT NULL,
    `score` INT NOT NULL,
    `total_marks` INT NOT NULL
);
