
-- Задание №10 

-- 1. Проанализировать какие запросы могут выполняться наиболее часто в
-- процессе работы приложения и добавить необходимые индексы.

USE vk;
-- Поиск по дате рождения 
CREATE INDEX profiles_birthday_idx ON profiles(birthday);
-- Поиск по стране проживание
CREATE INDEX profiles_country_idx ON profiles(country);
CREATE INDEX likes_like_type_idx ON likes(like_type);
-- Поиск по медиафайлам
CREATE INDEX media_filename_idx ON media(filename);
-- Поиск по сообществам
CREATE INDEX communities_name_idx ON communities(name);
-- Поиск по заголовкам постов
CREATE INDEX posts_head_idx ON posts(head);
-- Пользователю все время надо показывать непрочитанные его сообщения
CREATE INDEX profiles_is_read_idx ON messages(is_read);
CREATE FULLTEXT INDEX messages_body_idx ON messages(body);
CREATE INDEX messages_fuid_tuid_cat_idx ON messages(from_user_id, to_user_id, created_at);
CREATE INDEX messages_tuid_fuid_cat_idx ON messages(to_user_id, from_user_id, created_at);
CREATE INDEX profiles_fn_ln_pn_c_idx ON profiles(first_name, last_name, patronymic_name, city);
CREATE INDEX profiles_birthday_idx ON profiles(birthday);
CREATE INDEX profiles_country_idx ON profiles(country);


-- 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах
-- (общее количество пользователей в группе /  всего пользователей в системе) * 100

SELECT * FROM communities_users;

SELECT DISTINCT 
  c.name AS group_name,
  COUNT(cu.user_id) OVER() / (SELECT COUNT(*) FROM communities) AS avg_users_in_groups, -- (10 + 5 + 11) / 3
  FIRST_VALUE(CONCAT_WS(" ", p.first_name, p.last_name)) OVER w_community_birthday_desc AS youngest,
  FIRST_VALUE(CONCAT_WS(" ", p.first_name, p.last_name)) OVER w_community_birthday_asc AS oldest,
  COUNT(cu.user_id) OVER w_community AS users_in_group,
  (SELECT COUNT(*) FROM users) AS users_total,
  COUNT(cu.user_id) OVER w_community / (SELECT COUNT(*) FROM users) * 100 AS pct
    FROM communities c
      LEFT JOIN communities_users cu ON cu.community_id = c.id
      LEFT JOIN users u ON u.id = cu.user_id
      LEFT JOIN profiles p ON p.user_id = u.id
      WINDOW w_community AS (PARTITION BY c.id),
             w_community_birthday_desc AS (PARTITION BY c.id ORDER BY p.birthday DESC),
             w_community_birthday_asc AS (PARTITION BY c.id ORDER BY p.birthday)
;



