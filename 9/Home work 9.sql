-- Задание №9
-- 1. Практическое задание по теме “Транзакции, переменные, представления”
-- 1.1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
  INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
  DELETE FROM shop.users WHERE id = 1;
COMMIT;

-- 1.2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
use shop;

CREATE OR REPLACE VIEW product_and_catalog_names_view AS
SELECT
  p.name AS product,
  c.name AS catalog
FROM products AS p
JOIN catalogs AS c ON p.catalog_id = c.id;

SELECT * FROM product_and_catalog_names_view;

-- 1.3. (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи
-- за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный
-- список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.


-- 1.4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет
-- устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

-- находим 5 свежих записей
select created_at
from table_name
order by created_at
limit 5;

-- удаляем все записи, кроме найденых
WITH top AS (select created_at from table_name order by created_at limit 5)
DELETE from table_name
WHERE created_at NOT IN top;

-- Задание №9 2. Практическое задание по теме “Администрирование MySQL”
-- 2.1. Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть
-- доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.
CREATE USER IF NOT EXISTS 'user_one'@'localhost' identified BY '1234';
GRANT SELECT ON shop.* TO 'user_one'@'localhost';

CREATE USER IF NOT EXISTS 'user_two'@'localhost' identified BY '1234';
GRANT ALL ON shop.* TO 'shop'@'localhost';

-- 2.2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ,
-- имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.
CREATE OR REPLACE VIEW accounts_view AS
SELECT id, name FROM accounts;

CREATE USER IF NOT EXISTS 'accounts_view_user'@'localhost' identified BY '1234';
GRANT SELECT ON accounts_view TO 'accounts_view_user'@'localhost';

-- ### 3. Практическое задание по теме “Хранимые процедуры и функции, триггеры"
-- 3.1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро",
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

drop function if exists hello;

create function hello()
returns text no sql
begin
    declare now_hour INT;
    set now_hour = hour(now());
    case
        when now_hour >= 6 and now_hour < 12 then return "Доброе утро";
        when now_hour >= 12 and now_hour < 18 then return "Добрый день";
        when now_hour >= 18 or (now_hour >= 0 and now_hour < 6) then return "Доброй ночи";
    end case;
end

select hello();
select hour(now());

-- 3.2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.
DROP TRIGGER IF EXISTS validate_name_description_insert;
DROP TRIGGER IF EXISTS validate_name_description_update;

DELIMITER //

CREATE TRIGGER validate_name_description_insert BEFORE INSERT ON products FOR EACH ROW
BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot INSERT if name & description are NULL';
  END IF;
END//

CREATE TRIGGER validate_name_description_update BEFORE UPDATE ON products FOR EACH ROW
BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot UPDATE if name & description are NULL';
  END IF;
END//
DELIMITER ;
-- 3.3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.
DROP FUNCTION IF EXISTS FIBONACCI;

DELIMITER //
CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE fs DOUBLE;
  SET fs = SQRT(5);
  RETURN (POW((1 + fs) / 2.0, num) + POW((1 - fs) / 2.0, num)) / fs; -- Формула Бине
END//

DELIMITER ;

SELECT FIBONACCI(1);
SELECT FIBONACCI(2);
SELECT FIBONACCI(3);