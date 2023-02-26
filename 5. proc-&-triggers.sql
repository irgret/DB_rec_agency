/* 1. Процедура, которая подсчитывает количество закрытых проектов за год и сравнивает их с планом */
DELIMITER // 
SET @z = 10// -- это план по закрытию проектов в год
SET @a = '2019-01-01'// -- это начало года
SET @b = '2019-12-31'// -- конец года
DROP PROCEDURE IF EXISTS p1//
CREATE PROCEDURE p1 (inout value INT) COMMENT ''
	BEGIN 
			SET @x = value;
            SET value = @z - value;
	END//
    
SET @y = (SELECT COUNT(*) FROM orders o 
				WHERE o.order_status_id = (SELECT os.id FROM order_status os WHERE os.name = 'завершен')
				AND o.created_at BETWEEN @a AND @b);

CALL p1(@y);

SELECT @z as 'план', @x as 'факт', @y as 'до выполнения плана';p1

/* 2. Два простых триггера по недопущению изменения даты рождения на дату позднее текущего дня 
и по недопущению изначального ввода неправильной даты рождения */
DELIMITER // 
DROP TRIGGER IF EXISTS check_user_age_before_update//
CREATE TRIGGER check_user_age_before_update BEFORE UPDATE ON users_profiles
FOR EACH ROW
	begin 
		IF new.birthday > CURRENT_DATE() THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата рождения не может быть больше текущей даты';
		END IF;
	END //


DELIMITER // 
DROP TRIGGER IF EXISTS check_user_age_before_insert//
CREATE TRIGGER check_user_age_before_insert BEFORE INSERT ON users_profiles
FOR EACH ROW
	begin 
		IF new.birthday > CURRENT_DATE() THEN
			SET NEW.birthday = CURRENT_DATE();
		END IF;
	END //
