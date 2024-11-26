
-- 1 Вывести названия книг с количеством страниц 100 и более,
--   выпущенных после 2010 года, авторы которых родились до 1980 года
SELECT book.book_title
	FROM book JOIN author ON book.author_id=author.author_id
	WHERE book.publication_year > '20101231' 
		AND book.page_count >= 100 AND author.birth_year < '19800101';


-- 2 Вывести имена авторов из Праги (Prague) или Солсбери (Salisbury),
--   у которых есть книги, выпущенне не на английском (English) языке
SELECT author_name 
	FROM author JOIN book ON book.author_id=author.author_id 
	WHERE language != 'English' AND (birth_city = 'Prague' or birth_city = 'Salisbury');
	

-- 3 Вывести ТОП-1 самых популярных жанров книг, по количеству книг, выпущенных с 2002 года
SELECT DISTINCT genre_name
	FROM book 
	JOIN (SELECT genre_id, count(genre_id) as count_book
			FROM book
			WHERE publication_year >= '20020101'
			GROUP BY genre_id) book2 ON book.genre_id=book2.genre_id
	JOIN genre ON book.genre_id=genre.genre_id
	WHERE count_book = (SELECT max(count_book)
						FROM book 
						JOIN (SELECT genre_id, count(genre_id) as count_book
								FROM book
								WHERE publication_year >= '20020101'
								GROUP BY genre_id) book2 ON book.genre_id=book2.genre_id
						JOIN genre ON book.genre_id=genre.genre_id);

