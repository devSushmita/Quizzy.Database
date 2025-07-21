DROP PROCEDURE IF EXISTS usp_get_leaderboard;

DELIMITER $$

CREATE PROCEDURE usp_get_leaderboard(
    IN p_quiz_id INT
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_get_leaderboard';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;
    DECLARE l_tmp_table_name VARCHAR(64);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET l_params = CONCAT('p_quiz_id=', p_quiz_id);

        GET DIAGNOSTICS CONDITION 1
            l_sqlstate = RETURNED_SQLSTATE,
            l_error_code = MYSQL_ERRNO;

        CALL usp_log_error(
            l_storedprocedure_name,
            l_error_code,
            l_sqlstate,
            l_params,
            l_message
        );
    END;

    SET l_tmp_table_name = CONCAT(
        'tmp_per_score_',
        DATE_FORMAT(UTC_TIMESTAMP(3), '%Y%m%d%H%i%s%f')
    );

    SET @sql = CONCAT('
        CREATE TEMPORARY TABLE ', l_tmp_table_name, ' (
            user_id INT,
            quiz_id INT,
            per_score DECIMAL(10,2),
            PRIMARY KEY (user_id, quiz_id)
        ) ENGINE=MEMORY;
    ');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT('
        INSERT INTO ', l_tmp_table_name, ' (user_id, quiz_id, per_score)
        SELECT user_id, quiz_id, SUM(score) * 100 / SUM(total_marks)
        FROM tblSubmissions
        GROUP BY user_id, quiz_id;
    ');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    IF p_quiz_id IS NOT NULL THEN
        SET @sql = CONCAT('
            SELECT t.user_id, u.firstname, u.lastname,
                   ROUND(t.per_score, 2) AS overall_score
            FROM ', l_tmp_table_name, ' t
            INNER JOIN tblUsers u ON t.user_id = u.id
            WHERE t.quiz_id = ', p_quiz_id, '
            ORDER BY overall_score DESC, u.firstname ASC, u.lastname ASC
            LIMIT 5;
        ');
    ELSE
        SET @sql = CONCAT('
            SELECT t.user_id, u.firstname, u.lastname,
                   ROUND(AVG(t.per_score), 2) AS overall_score,
                   COUNT(t.quiz_id) AS attempted_quiz
            FROM ', l_tmp_table_name, ' t
            INNER JOIN tblUsers u ON t.user_id = u.id
            GROUP BY t.user_id
            ORDER BY overall_score DESC, u.firstname ASC, u.lastname ASC
            LIMIT 5;
        ');
    END IF;

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT('DROP TEMPORARY TABLE IF EXISTS ', l_tmp_table_name, ';');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END $$

DELIMITER ;
