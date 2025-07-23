DROP PROCEDURE IF EXISTS usp_get_questions;

DELIMITER $$

CREATE PROCEDURE usp_get_questions (
    IN p_ids VARCHAR(1024)
)
BEGIN
    DECLARE l_storedprocedure_name VARCHAR(256) DEFAULT 'usp_get_questions';
    DECLARE l_sqlstate CHAR(5);
    DECLARE l_error_code INT;
    DECLARE l_params TEXT;
    DECLARE l_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET l_params = CONCAT('p_ids=', p_ids);

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

        RESIGNAL;
    END;

    SELECT
        id,
        title,
        `level`,
        marks,
        answer_id,
        topic_id,
        created_at,
        updated_at,
        created_by,
        updated_by
    FROM tblQuestions q
    LEFT JOIN tblOptions o ON o.question_id = q.id
    AND JSON_ARRAYAGG(JSON_OBJECT('id', o.id, 'value', o.value)) AS options
    WHERE FIND_IN_SET(q.id, p_ids)
    GROUP BY q.id;
    
END$$

DELIMITER ;
