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



-- 3 ИЗМЕНЕНИЕ ДАННЫХ --------------------------------------------------------------- [BEGIN]

-- 3.1 Добавить новый объект инфраструктуры в клуб:
--     facid: 9, Name: 'Spa', membercost: 20, 
--     guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800
INSERT INTO cd.facilities 
		(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
	VALUES (9, 'Spa', 20, 30, 100000, 800);

-- 3.2 Добавить несколько новых объектов инфраструктуры в клуб:
--     facid: 9, Name: 'Spa', membercost: 20, 
--     guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800;
--     facid: 10, Name: 'Squash Court 2', membercost: 3.5, 
--     guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.
INSERT INTO cd.facilities 
		(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
	VALUES 
		(9, 'Spa', 20, 30, 100000, 800),
		(10, 'Squash Court 2', 3.5, 17.5, 5000, 80);

-- 3.3 Добавить новый объект инфраструктуры в клуб, 
--     но его номер (facid) вычисляется автоматически:
--     Name: 'Spa', membercost: 20, 
--     guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800
INSERT INTO cd.facilities 
		(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
	SELECT 
		(SELECT facid + 1 FROM cd.facilities
			ORDER BY facid DESC LIMIT 1), 'Spa', 20, 30, 100000, 800;

-- 3.4 Обновить значение первоначальных затрат на 2й теннисном корте (8000 -> 10000)
UPDATE cd.facilities
	SET initialoutlay = 10000
	WHERE name = 'Tennis Court 2';

-- 3.5 Обновить цены на теннисные корты (-> 6 для участников и -> 30 для гостей)
UPDATE cd.facilities
	SET membercost = 6, guestcost = 30
	WHERE name LIKE 'Tennis Court%';

-- 3.6 Обновить цены на 2й теннисный корт так, чтобы он стоил на 10% дороже 1го
UPDATE cd.facilities
	SET membercost = (SELECT membercost*1.1 FROM cd.facilities WHERE name = 'Tennis Court 1'),
		guestcost = (SELECT guestcost*1.1 FROM cd.facilities WHERE name = 'Tennis Court 1')
	WHERE name = 'Tennis Court 2';
-- или
UPDATE cd.facilities fac
	SET membercost = fac2.membercost * 1.1, guestcost = fac2.guestcost * 1.1
	FROM (SELECT membercost, guestcost FROM cd.facilities WHERE name = 'Tennis Court 1') fac2
	WHERE fac.name = 'Tennis Court 2';

-- 3.7 Очистить содержимое таблицы бронирований
DELETE FROM cd.bookings;
-- или 
TRUNCATE cd.bookings;

-- 3.8 Удалить участника №37 т.к. он никогда не совершал бронирований
DELETE FROM cd.members WHERE memid = 37;

-- 3.9 Удалить всех участников, которые никогда не совершали бронирований
DELETE FROM cd.members mem 
	WHERE mem.memid NOT IN (SELECT DISTINCT bks.memid FROM cd.bookings bks);
-- или
DELETE FROM cd.members mem
	WHERE NOT EXISTS (SELECT 1 FROM cd.bookings bks WHERE bks.memid = mem.memid);

-- 3 ИЗМЕНЕНИЕ ДАННЫХ ----------------------------------------------------------------- [END]



-- 4 АГРЕГАТОРЫ --------------------------------------------------------------------- [BEGIN]
-- 4.1 Подсичтать общее количество объектов
SELECT count(facid) FROM cd.facilities;

-- 4.2 Подсчитать количество объектов, 
--     стоимость которых для гостей составляет 10 или более долларов
SELECT count(facid) FROM cd.facilities WHERE guestcost >= 10;

-- 4.3 Подсчитать количество рекомендаций, которые дал каждый участник. 
--     Упорядочить по ID участника
SELECT recommendedby, count(*)
	FROM cd.members
	WHERE recommendedby IS NOT NULL
	GROUP BY recommendedby
	ORDER BY recommendedby;

-- 4.4 Составить список общего количества слотов, забронированных для каждого объекта.
--     Отсортировать по идентификатору объекта
SELECT facid, sum(slots) AS "Total Slots"
	FROM cd.bookings
	GROUP BY facid
	ORDER BY slots;

-- 4.5 Составить список общего количества слотов, забронированных для каждого объекта.
--     В сентябре 2012. Отсортировать по количеству слотов
SELECT facid, sum(slots) AS "Total Slots"
	FROM cd.bookings
	WHERE date(starttime) >= '2012-09-01' AND date(starttime) < '2012-10-01'
	GROUP BY facid
	ORDER BY sum(slots);


-- 4.6 Составить список общего количества слотов, забронированных для каждого объекта.
--     В каждом месяце 2012 года отдельно. Отсортировать по количеству слотов и месяцу
SELECT facid, EXTRACT(MONTH FROM date(starttime)) AS month, sum(slots) AS "Total Slots"
	FROM cd.bookings
	WHERE EXTRACT(YEAR FROM date(starttime)) = '2012'
	GROUP BY facid, month
	ORDER BY facid, month;

-- 4.7 Общее количество людей, которые следали хотя бы одно бронирование
SELECT count(DISTINCT memid) FROM cd.bookings;

-- 4.8 Составить список объектов, на которых забронировано более 1000 слотов. 
--     Отсортированных по идентификатору объектов
SELECT facid, sum(slots) AS "Total Slots"
	FROM cd.bookings
	GROUP BY facid
	HAVING sum(slots) > 1000
	ORDER BY facid;

-- 4.9 Составить список объектов с указанием их общего дохода.
--     Отсортированных по доходу
SELECT fac.name, sum(CASE
						WHEN bkg.memid = 0 THEN fac.guestcost * bkg.slots
						ELSE fac.membercost * bkg.slots
					END) AS revenue
	FROM cd.bookings bkg
		JOIN cd.facilities fac ON bkg.facid = fac.facid
	GROUP BY fac.name
	ORDER BY revenue;

-- 4.10 Составить список объектов с общим доходом менее 1000 долларов.
--      Отсортированных по доходу
SELECT fac.name, sum(CASE
						WHEN bkg.memid = 0 THEN fac.guestcost * bkg.slots
						ELSE fac.membercost * bkg.slots
					END) AS revenue
	FROM cd.bookings bkg
		JOIN cd.facilities fac ON bkg.facid = fac.facid
	GROUP BY fac.name
	HAVING sum(CASE
				WHEN bkg.memid = 0 THEN fac.guestcost * bkg.slots
				ELSE fac.membercost * bkg.slots
			END) < 1000
	ORDER BY revenue;
-- или
SELECT name, revenue 
	FROM (SELECT fac.name, sum(CASE 
								WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
								ELSE bkg.slots * fac.membercost
							END) AS revenue
			FROM cd.bookings bkg
				JOIN cd.facilities fac ON bkg.facid = fac.facid
			GROUP BY fac.name
		) AS agg 
	WHERE revenue < 1000
	ORDER BY revenue;  

-- 4.11 Вывести идентификатор объекта, у которого забронировано наибольшее количество слотов
SELECT facid, sum(slots) AS "Total Slots"
	FROM cd.bookings
	GROUP BY facid
	ORDER BY "Total Slots" DESC
	LIMIT 1	;
-- или
SELECT facid, sum(slots) AS "Total Slots"
	FROM cd.bookings
	GROUP BY facid
	HAVING sum(slots) = (SELECT max(sum1) 
							FROM (SELECT sum(slots) AS sum1 
									FROM cd.bookings 
									GROUP BY facid) 
							AS agg);
-- или
WITH sum_ AS (SELECT facid, sum(slots) AS sum1 
				FROM cd.bookings 
				GROUP BY facid)
SELECT facid, sum1
	FROM sum_
	WHERE sum1 = (SELECT max(sum1) FROM sum_);

-- 4.12 Составить список общего количества слотов, забронированных для каждого объекта.
--      В каждом месяце 2012 года отдельно. Добавить общее количество по одному объекту 
--      за все месяцы и общее по всем объектам за все время (верхние уровни агрегации).
--      Отсортировать по количеству слотов и месяцу
SELECT facid, EXTRACT(MONTH FROM date(starttime)) AS month, sum(slots) AS "Total Slots"
	FROM cd.bookings
	WHERE EXTRACT(YEAR FROM date(starttime)) = '2012'
	GROUP BY ROLLUP (facid, month)
	ORDER BY facid, month;

-- 4.13 Составить список общего количества часов, забронированных на каждом объекте 
--      (слот = полчаса). Сортировка по идентификатору объекта. 
--      Отформатировать количество часов с точностью до двух знаков после запятой
SELECT fac.facid, fac.name, sum(bkg.slots)*0.50 AS "Total Hours"
	FROM cd.facilities fac 
		JOIN cd.bookings bkg ON bkg.facid = fac.facid
	GROUP BY fac.facid, fac.name
	ORDER BY fac.facid;
-- или
SELECT fac.facid, fac.name, 
		trim(to_char(sum(bkg.slots)*0.5, '9999999999999999D99')) AS "Total Hours"
	FROM cd.facilities fac 
		JOIN cd.bookings bkg ON bkg.facid = fac.facid
	GROUP BY fac.facid, fac.name
	ORDER BY fac.facid;

-- 4.14 Составить список всех участников с указанием их имён, идентификаторов 
--      и первого бронирования после 1 сентября 2012 года. 
--      Сортировка по идентификатору участника
SELECT mem.surname, mem.firstname, mem.memid, min(bkg.starttime)
	FROM cd.members mem JOIN cd.bookings bkg ON bkg.memid = mem.memid
	WHERE bkg.starttime > '2012-09-01'
	GROUP BY mem.surname, mem.firstname, mem.memid
	ORDER BY mem.memid;

-- 4.15 Вывести список имён участников, в каждой строке указав общее количество участников. 
--      Сортировка по дате вступления
SELECT (SELECT count(*) FROM cd.members), firstname, surname
	FROM cd.members
	ORDER BY joindate;
-- или
SELECT count(*) OVER(), firstname, surname
	FROM cd.members
	ORDER BY joindate;

-- 4.16 Создать монотонно возрастающий пронумерованный список участников (включая гостей), 
--      упорядоченный по дате их присоединения
SELECT row_number() OVER(ORDER BY joindate), firstname, surname FROM cd.members;

-- 4.17 Вывести идентификатор объекта, у которого забронировано наибольшее количество слотов.
--      Использовать оконные функции
SELECT facid, "Total"
	FROM (SELECT facid, sum(slots) AS "Total", rank() OVER(ORDER BY sum(slots) DESC) AS rank
			FROM cd.bookings
			GROUP BY facid) AS ranked
	WHERE rank = 1;

-- 4.18 Составить список участников (включая гостей) с указанием количества часов, 
--      которые они провели в помещениях, округлённых до ближайших десяти часов. 
--      Расставить их по рангу в соответствии с этим округлённым значением, 
--      указав имя, фамилию, округлённое количество часов и ранг. 
--      Сортировка по рангу, фамилии и имени.
SELECT mem.firstname, mem.surname, round(sum(bkg.slots*0.5), -1) AS hourse,
		rank() OVER(ORDER BY round(sum(bkg.slots*0.5), -1) DESC) AS rank
	FROM cd.members mem JOIN cd.bookings bkg ON mem.memid = bkg.memid
	GROUP BY mem.memid
	ORDER BY rank, mem.surname, mem.firstname

-- 4.19 Составить список трёх наиболее прибыльных объектов (включая дублирующие). 
--      Отсортировать по рейтингу
SELECT * 
	FROM (SELECT name, rank() OVER(ORDER BY revenue DESC) AS rank
			FROM (SELECT fac.name, sum(CASE 
										WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
										ELSE bkg.slots * fac.membercost
									END) AS revenue
					FROM cd.bookings bkg
						JOIN cd.facilities fac ON bkg.facid = fac.facid
					GROUP BY fac.name
					) AS agg 
			) AS agg2
	WHERE rank <= 3;

-- 4.20 Разделить объекты на группы одинакового размера с высоким, 
--      средним и низким доходом в зависимости от их выручки. 
--      Расположить порядке убывания по классификации и названию
SELECT name, CASE
			WHEN revenue_ = 1 THEN 'high'
			WHEN revenue_ = 2 THEN 'average'
			WHEN revenue_ = 3 THEN 'low'
			END AS revenue
	FROM (SELECT fac.name, 
				ntile(3) OVER(ORDER BY sum(CASE 
											WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
											ELSE bkg.slots * fac.membercost
										END) DESC) AS revenue_
			FROM cd.bookings bkg JOIN cd.facilities fac ON bkg.facid = fac.facid
			GROUP BY fac.name) AS agg 
	ORDER BY revenue_, name;

-- 4.21 Основываясь на имеющихся на данный момент данных за 3 полных месяца, рассчитать, 
--      сколько времени потребуется каждому объекту, чтобы окупить стоимость владения. 
--      Вывести название объекта и время окупаемости в месяцах 
--      в порядке возрастания названий объектов
SELECT name, initi/(rev-mainten) AS repaytime 
	FROM (SELECT fac.name AS name,
				fac.initialoutlay AS initi,
				fac.monthlymaintenance AS mainten,
				sum(CASE 
						WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
						ELSE bkg.slots * fac.membercost
					END)/3 AS rev
			FROM cd.bookings bkg JOIN cd.facilities fac ON bkg.facid = fac.facid
			GROUP BY fac.facid) AS subq
	ORDER BY name;

-- 4.22 Для каждого дня августа 2012 года рассчитать 
--      скользящее среднее значение общего дохода за предыдущие 15 дней. 
--      Результат должен содержать столбцы с датой и доходом, отсортированные по дате
WITH dailyrev AS (SELECT cast(bkg.starttime AS date) AS date,
			sum(CASE 
					WHEN bkg.memid = 0 THEN bkg.slots * fac.guestcost
					ELSE bkg.slots * fac.membercost
				END) AS rev
		FROM cd.bookings bkg JOIN cd.facilities fac ON bkg.facid = fac.facid
		GROUP BY cast(bkg.starttime AS date))
SELECT date, avgrev 
	FROM (SELECT dategen.date AS date,
				avg(revdata.rev) OVER(ORDER BY dategen.date ROWS 14 PRECEDING) AS avgrev
			FROM (SELECT cast(generate_series(timestamp '2012-07-10', 
												'2012-08-31', 
												'1 day') AS date) AS date) AS dategen
				LEFT OUTER JOIN dailyrev AS revdata ON dategen.date = revdata.date
		) AS subq
	WHERE date >= '2012-08-01'
ORDER BY date;
-- 4 АГРЕГАТОРЫ ----------------------------------------------------------------------- [END]
