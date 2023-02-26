-- 1. Можем посмотреть полный список всех проектов с датами.
SELECT o.id AS '№ заказа', c.name AS 'Компания', p.name AS 'Наименование позиции заказа', 
	os.name AS 'Статус проекта', o.created_at AS 'Дата начала проекта' FROM orders o
		JOIN positions p
			ON o.position_id = p.id
		JOIN order_status os
			ON o.order_status_id = os.id
		JOIN companies c
			ON o.company_id = c.id
	ORDER BY o.id;

-- 2. Посмотрим, сколько новых проектов и проектов в работе у нас в 2020 году
SELECT os.name AS 'Тип проекта', COUNT(*) AS 'Всего в 2020' FROM orders o
	JOIN order_status os ON o.order_status_id = os.id
		WHERE order_status_id IN (SELECT os.id FROM order_status os WHERE os.name IN ('новый проект', 'в работе')) 
		AND o.created_at BETWEEN '2020-01-01' AND '2020-12-31'
	GROUP BY order_status_id;

-- 3. Посчитаем количество пользователей из разных городов.

SELECT hometown AS 'Город', COUNT(*) AS 'кол-во' FROM users_profiles
	GROUP BY hometown;

-- 4. Посчитаем количество пользователей всего и количество заполненных профилей.

SELECT 'Пользователей всего' AS '', COUNT(*) FROM users
	UNION
SELECT 'Заполненных профилей', COUNT(*) FROM users_profiles;

-- у кого-то не заполнен профиль, давайте найдем их
SELECT * FROM users 
	WHERE users.id NOT IN (SELECT up.user_id FROM users_profiles up, users u WHERE up.user_id = u.id);
    
-- 5. Давайте посмотрим, какие компании имеют сотрудников согласно нашей базе
SELECT c.id, c.name FROM companies c
	WHERE c.id IN (SELECT us.company_id FROM users_companies us)
ORDER BY c.id;

-- а теперь посмотрим, нет ли у нас в компании ПГК сотрудников с одинаковой должностью
SELECT c.name AS 'компания', c.fullname AS 'полное название', p.name AS 'должность', COUNT(p.name) AS 'кол-во' FROM companies c 
	JOIN users_companies uc
		ON c.id = uc.company_id
	JOIN positions p
		ON uc.position_id = p.id
	WHERE uc.company_id = (SELECT c.id FROM companies c WHERE c.name = 'ПГК')
GROUP BY p.name;
-- итого, у нас 2 директора по продажам.

-- 6. А теперь посмотрим, компании из какого сектора у нас не охвачены.
SELECT s.name FROM sector s 
	WHERE NOT s.id IN (SELECT cs.sector_id FROM companies_sector cs);