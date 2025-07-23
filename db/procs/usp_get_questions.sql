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
        q.id,
        q.title,
        q.`level`,
        q.marks,
        q.answer_id,
        q.topic_id,
        q.created_at,
        q.updated_at,
        q.created_by,
        q.updated_by,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'id',   o.id,
                'value', o.value
            )
        ) AS options
    FROM tblQuestions AS q
    LEFT JOIN tblOptions AS o
      ON o.question_id = q.id
    WHERE FIND_IN_SET(q.id, p_ids)
    GROUP BY
        q.id,
        q.title,
        q.`level`,
        q.marks,
        q.answer_id,
        q.topic_id,
        q.created_at,
        q.updated_at,
        q.created_by,
        q.updated_by;
END$$

DELIMITER ;
