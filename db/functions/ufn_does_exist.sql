DROP FUNCTION IF EXISTS ufn_does_exist;

DELIMITER $$

CREATE FUNCTION ufn_does_exist(p_id INTEGER, p_type TINYINT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE entity_count INT DEFAULT 0;

	-- quiz
	IF p_type = 1
    THEN
		SELECT COUNT(id)
		INTO entity_count
		FROM tblQuiz
		WHERE id = p_id;
	END IF;
    
    -- topic
    IF p_type = 2
    THEN
		SELECT COUNT(id)
		INTO entity_count
		FROM tblTopics
		WHERE id = p_id;
	END IF;
    
    RETURN entity_count > 0;
END$$

DELIMITER ;