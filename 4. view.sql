/* 1. Создадим представление, которое покажет нам соответствие компаний, проектов и статус их завершения. 
Похоже на запрос №1 из задания про типовые выборки с тем отличием, что в данном представлении мы отсортировали данные 
так, что можем видеть рядом заказы на одинаковые должности в одном статусе (например, завершен).
Это нам нужно для представления №2. */

DROP VIEW IF EXISTS v1;
CREATE VIEW v1 AS SELECT o.id AS '№ заказа', c.name AS 'Компания',
p.name AS 'Наименование позиции заказа', os.name AS 'Статус проекта', o.created_at AS 'Дата начала проекта'

	FROM orders o
		JOIN positions p
			ON o.position_id = p.id
		JOIN order_status os
			ON o.order_status_id = os.id
		JOIN companies c
			ON o.company_id = c.id
ORDER BY o.order_status_id DESC, p.id;
    
SELECT * FROM v1;

/* 2. Итак, мы видим, что 2 компании заказывали поиск Коммерческого директора и Директора по логистике.
Значит уже можно узнать средние данные по закрываемости вакансии. 
Я имею в виду - сколько в среднем нужно показать кандидатов, чтобы вакансия закрылась. Итак, приступим. */
DROP VIEW IF EXISTS v2;
CREATE VIEW v2 AS 
		(SELECT '1 компания' AS companies, COUNT(*) AS quantity FROM users_orders uo
			WHERE uo.order_id IN (SELECT o.id FROM orders o WHERE o.position_id = (SELECT p.id FROM positions p WHERE p.name = 'Коммерческий директор')
			AND o.order_status_id = (SELECT os.id FROM order_status os WHERE os.name = 'завершен')
			AND o.company_id = (SELECT c.id FROM companies c WHERE c.name = 'ПГК')))
	UNION
		(SELECT '2 компания', COUNT(*) FROM users_orders uo
			WHERE uo.order_id = (SELECT o.id FROM orders o WHERE o.position_id = (SELECT p.id FROM positions p WHERE p.name = 'Коммерческий директор')
			AND o.order_status_id = (SELECT os.id FROM order_status os WHERE os.name = 'завершен')
			AND o.company_id = (SELECT c.id FROM companies c WHERE c.name = 'УралКалий')));
            
	SELECT * FROM v2;
    SELECT AVG(quantity) FROM v2;
/* то есть, в среднем мы показыали, 3,5 человека прежде, чем вакансия закрывалась.
Изменив в представлении выше название должности на Директор по логистике, 
мы узнаем средние данные и по этой вакансии.*/