DROP DATABASE IF EXISTS experium;
CREATE DATABASE experium;
USE experium;

DROP TABLE IF EXISTS users; -- 1. кандидаты
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone BIGINT,
    INDEX users_phone_idx(phone),
    INDEX users_email_idx(email),
    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT = 'Кандидаты';

DROP TABLE IF EXISTS users_profiles; -- 2. профиль юзера
CREATE TABLE users_profiles (
	user_id SERIAL PRIMARY KEY,
	gender CHAR(1),
	birthday DATE,
	hometown VARCHAR(100),
    `comment` text,
	created_at DATETIME DEFAULT NOW(),
	FOREIGN KEY (user_id) references users(id)
) COMMENT = 'Карточка человека';

DROP TABLE IF EXISTS companies; -- 3. компании
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL, -- обязательно
    fullname VARCHAR(255), -- полное название компании (необязательно)
    INDEX companies_name_idx(name)
) COMMENT = 'Компании';

DROP TABLE IF EXISTS companies_profiles; -- 4. карточка компании
CREATE TABLE companies_profiles (
	company_id SERIAL PRIMARY KEY,
	email VARCHAR(100),
    phone BIGINT,
	adress VARCHAR(255),
    `comment` text,
	created_at DATETIME DEFAULT NOW(),
    update_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (company_id) references companies(id)
) COMMENT = 'Карточка компании';

DROP TABLE IF EXISTS sector; -- 5. типы отраслей
CREATE TABLE sector (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
	created_at DATETIME DEFAULT NOW(),
    update_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Отрасль, сектор';

DROP TABLE IF EXISTS positions; -- 6. виды должностей
CREATE TABLE positions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
	created_at DATETIME DEFAULT NOW(),
    update_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Должность';

DROP TABLE IF EXISTS users_sector; -- 7. юзеры - отрасли (чтобы не было свзи "многие-ко-многим")
CREATE TABLE users_sector (
    user_id BIGINT UNSIGNED NOT NULL,
	sector_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, sector_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (sector_id) REFERENCES sector(id)
) COMMENT = 'Отрась специализации кандидата';

DROP TABLE IF EXISTS companies_sector; -- 8. компании - отрасли
CREATE TABLE companies_sector (
    company_id BIGINT UNSIGNED NOT NULL,
	sector_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (company_id, sector_id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (sector_id) REFERENCES sector(id)
) COMMENT = 'Отрасль компании';

DROP TABLE IF EXISTS users_companies; -- 9. список сотрудников компании
CREATE TABLE users_companies (
    user_id BIGINT UNSIGNED NOT NULL,
    company_id BIGINT UNSIGNED NOT NULL,
	position_id BIGINT UNSIGNED NULL, -- можем не знать должность
    
	PRIMARY KEY (user_id, company_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (position_id) REFERENCES positions(id)
) COMMENT = 'Список сотрудников';

DROP TABLE IF EXISTS documents_type; -- 10. тип документа, прикрепляемого к карточке человека или компании
CREATE TABLE documents_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Тип документа';

DROP TABLE IF EXISTS users_documents; -- 11. документы юзеров (резюме, рекомендации и т.д.)
CREATE TABLE users_documents (
    user_id BIGINT UNSIGNED NOT NULL,
    documents_type_id BIGINT UNSIGNED NOT NULL,
    filename VARCHAR(255),
    size INT,
	metadata JSON, 
    `comment` text,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX (user_id),
    PRIMARY KEY (user_id, documents_type_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (documents_type_id) REFERENCES documents_type(id)
) COMMENT = 'Документы кандидата';

DROP TABLE IF EXISTS companies_documents; -- 12. документы компаний (договоры, офферы и т.д.)
CREATE TABLE companies_documents (
    company_id BIGINT UNSIGNED NOT NULL,
    documents_type_id BIGINT UNSIGNED NOT NULL,
    filename VARCHAR(255),
    size INT,
	metadata JSON,
    `comment` text,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX (company_id),
    PRIMARY KEY (company_id, documents_type_id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (documents_type_id) REFERENCES documents_type(id)
) COMMENT = 'Документы компании';

DROP TABLE IF EXISTS order_status; -- 13. статус проекта (новый проект, в работе, завершен)
CREATE TABLE order_status (
    id SERIAL PRIMARY KEY,
	name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Статус проекта';

DROP TABLE IF EXISTS orders; -- 14. заказы от компаний на поиск по разным позициям (одна компания ищет, например, директора, менеджера и бухгалтера)
CREATE TABLE orders (
	id SERIAL PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    order_status_id BIGINT UNSIGNED DEFAULT 1,
    position_id BIGINT UNSIGNED NOT NULL,
    created_at DATE NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX (company_id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (order_status_id) REFERENCES order_status(id),
    FOREIGN KEY (position_id) REFERENCES positions(id)
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS user_status; -- 15. тип юзера в заказе (кандидат, претендент, финалист, сотрудник)
CREATE TABLE user_status (
    id SERIAL PRIMARY KEY,
	name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Статус кандидата';

DROP TABLE IF EXISTS users_orders; -- 16. кандидат - заказ (кандидат может быть представлен в много компаний и заказов и один заказ может содержать много кандидатов) 
CREATE TABLE users_orders (
    order_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	user_status_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
    `comment` text,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
	PRIMARY KEY (order_id, user_id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (user_status_id) REFERENCES user_status(id)
) COMMENT = 'Список представленных кандидатов';

