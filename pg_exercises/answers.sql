-- 1 ПРОСТЫЕ SQL-ЗАПРОСЫ ------------------------------------------------------------ [BEGIN]

-- 1.1 Вывести всю информацию из таблицы cd.facilities
SELECT * FROM cd.facilities;

-- 1.2 Вывести список объектов и их стоимость для участников клуба
SELECT name, membercost FROM cd.facilities;

-- 1.3 Вывести список объектов, за которые взимается плата
SELECT * FROM cd.facilities WHERE membercost != 0;

-- 1.4 Вывести список объектов, за которые взимается плата с участников, 
--     и эта плата составляет менее 1/50 ежемесячных расходов на обслуживание
SELECT facid, name, membercost, monthlymaintenance
	FROM cd.facilities
	WHERE membercost != 0 AND membercost < monthlymaintenance/50;

-- 1.5 Вывести список всех объектов инфраструктуры, в назавнии которых есть слово "Tennis"
SELECT * FROM cd.facilities WHERE name LIKE '%Tennis%';

-- 1.6 Вывести сведения об объектах с индетификаторами 1 и 5
SELECT * FROM cd.facilities WHERE facid IN (1,5);

-- 1.7 Вывести список объектов, каждый из которых будет помечен как "expensive" или "cheap" 
--     в зависимости от того стоит ли их ежемесячное обслуживание более 100 единиц 
SELECT name, 
		CASE WHEN monthlymaintenance > 100 THEN
			'expensive'
		ELSE
			'cheap'
		END AS cost
	FROM cd.facilities;

-- 1.8 Вывести идентификатор, фамилию, имя и дату присоединения участников, 
--     присоединившихся к клубу после начала сентября 2012 года
SELECT memid, surname, firstname, joindate
	FROM cd.members
	WHERE joindate >= '2012-09-01';

-- 1.9 Вывести упорядоченный список из первых 10 фамилий в таблице участников.
--     Список не должен содержать дубликатов
SELECT DISTINCT surname FROM cd.members ORDER BY surname LIMIT 10;

-- 1.10 Вывести объединенный список из фамилий участников и объектов инфраструктуры
SELECT surname FROM cd.members
	UNION
	SELECT name FROM cd.facilities;

-- 1.11 Вывести дату регистрации последнено участника
SELECT firstname, surname, joindate FROM cd.members 
	WHERE joindate = (SELECT max(joindate) FROM cd.members);

-- 1 ПРОСТЫЕ SQL-ЗАПРОСЫ -------------------------------------------------------------- [END]



-- 2 СОЕДИНЕНИЯ И ПОДЗАПРОСЫ -------------------------------------------------------- [BEGIN]

-- 2.1 Вывести список времени начала бронирования для участников по имени "David Farrell"
SELECT bks.starttime 
	FROM cd.bookings bks JOIN cd.members mem ON bks.memid = mem.memid
	WHERE mem.surname = 'Farrell' AND mem.firstname = 'David';

-- 2.2 Вывести список времени начала занятий на теннисных кортах на 21 сентября 2012. 
--     Вернуть пары из времени начала занятий и названия объекта, упорядоченные по времени.
SELECT bks.starttime as start, fac.name 
	FROM cd.bookings bks JOIN cd.facilities fac ON bks.facid = fac.facid
	WHERE date(bks.starttime) = '2012-09-21' AND fac.name LIKE 'Tennis%'
	ORDER BY bks.starttime;

-- 2.3 Вывести список всех участников, которые порекомдовали другого участника. 
--     Без дубликатов и упорядоченно по фамилии и имени
SELECT mem.firstname, mem.surname FROM cd.members mem 
	WHERE mem.memid IN 
		(SELECT DISTINCT mem1.recommendedby FROM cd.members mem1 
		WHERE mem1.recommendedby IS NOT NUll)
	ORDER BY mem.surname, mem.firstname;
-- или
SELECT DISTINCT mem.firstname, mem.surname
	FROM cd.members mem INNER JOIN cd.members mem1 ON mem.memid = mem1.recommendedby
	ORDER BY mem.surname, mem.firstname;  

-- 2.4 Вывести список всех участников и тех, кто их рекомендовал (при наличии).
--     Упорядоченно по фамилии и имени
SELECT mem.firstname AS memfname, mem.surname AS memsname, 
		mem1.firstname AS recfname, mem1.surname AS recsname
	FROM cd.members mem LEFT OUTER JOIN cd.members mem1 ON mem.recommendedby = mem1.memid
	ORDER BY memsname, memfname;  

-- 2.5 Вывести список всех участников, которые пользовались теннисным кортом.
--     Имя и фамилию участника в один столбец; отстуствие полных дубликатов;
--     упорядоченно по имени и названию объекта
SELECT DISTINCT mem.firstname || ' ' || mem.surname AS member,
		fac.name AS facility
	FROM cd.members mem 
		JOIN (cd.bookings bks JOIN cd.facilities fac ON bks.facid = fac.facid) 
			ON mem.memid = bks.memid
	WHERE fac.name LIKE 'Tennis%'
	ORDER BY member, facility;

-- 2.6 Вывести список бронирований на 14 сентября 2012, которые стоят более 30 единиц.
--     Вывод: имя участника / гость в один столбец, название объекта, стоимость.
--     В порядке убывания стоимости; без подзапросов.
--     Стоимость для гостей != стоимости для участников; id гостя = 0
SELECT mem.firstname || ' ' || mem.surname AS member,
		fac.name AS facility, 
		CASE WHEN mem.memid = 0 THEN
			fac.guestcost * bks.slots
		ELSE
			fac.membercost * bks.slots
		END AS cost
	FROM cd.members mem 
	JOIN cd.bookings bks ON mem.memid = bks.memid
	JOIN cd.facilities fac ON fac.facid = bks.facid
	WHERE date(bks.starttime) = '2012-09-14'
		AND (
			(mem.memid = 0 AND fac.guestcost * bks.slots > 30) OR
			(mem.memid != 0 AND fac.membercost * bks.slots > 30)
		)
	ORDER BY cost DESC;

-- 2.7 Вывести список всех участников и тех, кто их рекомендовал (при наличии).
--     Упражнение 2.4.
--     Без объединений. Без дубликатов; имя+фамилия в один упорядоченный столбец
SELECT DISTINCT mem.firstname || ' ' || mem.surname AS member, 
		(SELECT mem1.firstname || ' ' || mem1.surname AS recommender 
		FROM cd.members mem1 
		WHERE mem1.memid = mem.recommendedby) 
	FROM cd.members mem
	ORDER BY member;

-- 2.8 Упражнение 2.6. Но нужно упростить*, используя подзапросы
--     *столбец cost вычисляется только один раз
SELECT member, facility, cost 
	FROM (
		SELECT mem.firstname || ' ' || mem.surname AS member,
				fac.name AS facility,
				CASE WHEN mem.memid = 0 THEN
					fac.guestcost * bks.slots
				ELSE
					fac.membercost * bks.slots
				END AS cost
			FROM cd.members mem 
			JOIN cd.bookings bks ON mem.memid = bks.memid
			JOIN cd.facilities fac ON fac.facid = bks.facid
			WHERE date(bks.starttime) = '2012-09-14'
	) AS bookings20120914
	WHERE cost > 30
	ORDER BY cost DESC;

-- 2 СОЕДИНЕНИЯ И ПОДЗАПРОСЫ ---------------------------------------------------------- [END]
