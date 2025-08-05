DROP FUNCTION IF EXISTS ufn_does_topic_exist;

DELIMITER $$

CREATE FUNCTION ufn_does_topic_exist(topic_name VARCHAR(64))
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE topic_count INT;

    SELECT COUNT(*)
    INTO topic_count
    FROM tblTopics
    WHERE name = topic_name;

    RETURN topic_count > 0;
END$$

DELIMITER ;
