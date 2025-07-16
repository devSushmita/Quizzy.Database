DROP FUNCTION 
IF EXISTS ufn_is_admin;

DELIMITER $$

CREATE FUNCTION ufn_is_admin(p_user_id INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE l_administrator INT DEFAULT 1;
    DECLARE l_id INT;

    SELECT id
    INTO l_id
    FROM tblUsers
    WHERE id = p_user_id
    AND role_id = l_administrator;

    RETURN l_id IS NOT NULL;
END$$

DELIMITER ;
