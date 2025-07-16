DROP PROCEDURE IF EXISTS usp_get_leaderboard;

DELIMITER $$

CREATE PROCEDURE usp_get_leaderboard(
    IN p_quiz_id INT
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_get_leaderboard';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT DEFAULT 'N/A';
    DECLARE l_message TEXT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DROP TABLE IF EXISTS tblTempQuizScore;
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

    CREATE TEMPORARY TABLE tblTempQuizScore AS
    SELECT user_id, quiz_id, SUM(score) * 100 / SUM(total_marks) AS per_score
    FROM tblSubmissions
    GROUP BY user_id, quiz_id;

    IF p_quiz_id IS NOT NULL THEN
        SELECT
            ttqs.user_id,
            tu.firstname,
            tu.lastname,
            ROUND(ttqs.per_score, 2) AS overall_score
        FROM tblTempQuizScore AS ttqs
        INNER JOIN tblUsers AS tu ON ttqs.user_id = tu.id
        WHERE ttqs.quiz_id = p_quiz_id
        ORDER BY overall_score DESC, tu.firstname ASC, tu.lastname ASC
        LIMIT 5;
    ELSE
        SELECT
            ttqs.user_id,
            tu.firstname,
            tu.lastname,
            ROUND(AVG(ttqs.per_score), 2) AS overall_score,
            COUNT(ttqs.quiz_id) AS attempted_quiz
        FROM tblTempQuizScore AS ttqs
        INNER JOIN tblUsers AS tu ON ttqs.user_id = tu.id
        GROUP BY ttqs.user_id
        ORDER BY overall_score DESC, tu.firstname ASC, tu.lastname ASC
        LIMIT 5;
    END IF;
    
    DROP TABLE IF EXISTS tblTempQuizScore;
END $$

DELIMITER ;
