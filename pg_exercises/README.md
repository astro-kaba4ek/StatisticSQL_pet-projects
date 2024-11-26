# Решение задач с [PostgreSQL Exercises](https://pgexercises.com/) &mdash; сайта с различными упражненениями по PostgreSQL

Данный pet-проект предсталяет собой условия и решения (в конечном итоге) всех задач с сайта [PostgreSQL Exercises](https://pgexercises.com/), собранные в единый файл для удобства. Все решения написаны автором самостоятельно и не всегда совпадают с представленными ключами на сайте, но при этом полностью решают посталенные задачи.

## Постановка задачи: 

Тренировочная база данных (БД) предназначена для загородного клуба с набором участников, объектов инфраструктуры и историей бронирования этих объектов. Клуб хочет понять, как можно использовать эти данные для анализа использования объектов / спроса на них.

## БД состоит из трех таблиц:
![Изображение](https://pgexercises.com/img/schema-horizontal.svg)

Таблица с информацией об участниках и гостях клуба
```SQL
CREATE TABLE cd.members (
	memid			integer					NOT NULL,	-- идентификатор
	surname			character varying(200)	NOT NULL,	-- фамилия
	firstname		character varying(200)	NOT NULL,	-- имя
	address			character varying(300)	NOT NULL,	-- адрес
	zipcode			integer					NOT NULL,	-- почтовый индекс
	telephone		character varying(20)	NOT NULL,	-- телефон
	recommendedby	integer,							-- идентификатор того, кто порекомендовал этого участника (при наличии)
	joindate		timestamp				NOT NULL,	-- время присоединения к клубу
	CONSTRAINT members_pk PRIMARY KEY (memid),			-- memid - первичный ключ таблицы (значение уникальное и не пустое)
	CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby) 
		REFERENCES cd.members(memid) ON DELETE SET NULL	-- внешний ключ: только существующие участники и гости клуба, при удалении участника значение становится пустым
);
```

Таблица с информацией об объектах инфраструктуры клуба
```SQL
CREATE TABLE cd.facilities (
	facid				integer					NOT NULL,	-- идентификатор
	name				character varying(100)	NOT NULL,	-- название
	membercost			numeric					NOT NULL,	-- стоимость бронирования для членов клуба
	guestcost			numeric					NOT NULL,	-- стоимость бронирования для гостей клуба
	initialoutlay		numeric					NOT NULL,	-- стоимость строительства объекта
	monthlymaintenance	numeric					NOT NULL,	-- стоимость ежемесяного объслуживания
	CONSTRAINT facilities_pk PRIMARY KEY (facid)			-- facid - первичный ключ таблицы 
);
```

Таблица с информацией о бронировании объектов клуба
```SQL
CREATE TABLE cd.bookings (
	bookid		integer		NOT NULL,				-- идентификатор бронирования
	facid		integer		NOT NULL,				-- идентификатор объекта
	memid		integer		NOT NULL,				-- участник, сделавший бронирование
	starttime	timestamp	NOT NULL,				-- время начала бронирования
	slots		integer		NOT NULL,				-- количество получасовых сеансов
	CONSTRAINT bookings_pk PRIMARY KEY (bookid),	-- bookid - первичный ключ таблицы 
	CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) 
		REFERENCES cd.facilities(facid),			-- внешний ключ (только существующие объекты инфраструктуры)
	CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) 
		REFERENCES cd.members(memid)				-- внешний ключ (только существующие участники и гости клуба)
);
```


