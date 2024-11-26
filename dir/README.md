
# Решение "Экзамен SQL. Осень 2024" от [Т-Банк Образование](https://education.tbank.ru/start/) 

Данный pet-проект предсталяет собой условия и решения всех задач со вступительного экзамена на стажировку **DWH аналитика (осень 2024) / Аналитика (осень 2024)** от [Т-Банка](https://education.tbank.ru/start/), собранные в единый файл для удобства. Все решения написаны автором самостоятельно, и полностью прошли экзаменационные проверки.

## Постановка задачи: 

Существует база данных, хранящая информацию о литературных произведениях. Она состоит из трех таблиц, содержащих сведения о книгах, авторах и жанрах. Нужно получить различную информацию.

Формат хранения данных в таблицах и примеры самих данных:

### Таблица книги (book)
|Ключ|Наименование поля|
|-|-|
|PK	|book_id
|FK	|genre_id
|FK	|author_id
|	|book_title
|	|publication_year
|	|page_count
|	|language
```SQL
DROP TABLE IF EXISTS book; 

CREATE TABLE book AS (
SELECT 
	'123'					AS	book_id,
	'234'					AS	genre_id,
	'345'					AS	author_id,
	'To Kill a Mockingbird'	AS	book_title,
	'1962-01-01'::date		AS	publication_year,
	160						AS	page_count,
	'English'				AS	language
UNION ALL
SELECT 
	'234'					AS	book_id,
	'345'					AS	genre_id,
	'456'					AS	author_id,
	'Die Verwandlung'		AS	book_title,
	'1915-01-01'::date		AS	publication_year,
	80						AS	page_count,
	'German'				AS	language
UNION ALL
SELECT 
	'345'					AS	book_id,
	'456'					AS	genre_id,
	'567'					AS	author_id,
	'The Girl on the Train'		AS	book_title,
	'2015-01-01'::date		AS	publication_year,
	336						AS	page_count,
	'English'				AS	language
);
```

### Таблица авторы (author)
|Ключ|Наименование поля|
|-|-|
|PK	|author_id
|	|author_name
|	|birth_year
|	|birth_city
```SQL
DROP TABLE IF EXISTS author;

CREATE TABLE author AS (
SELECT 
	'345'				AS author_id,
	'Harper Lee'		AS author_name,
	'1926-04-28'::date	AS birth_year,
	'Monroeville'		AS birth_city
UNION ALL
SELECT 
	'456'				AS author_id,
	'Franz Kafka'		AS author_name,
	'1883-07-03'::date	AS birth_year,
	'Prague'			AS birth_city
UNION ALL
SELECT 
	'567'				AS author_id,
	'Paula Hawkins'		AS author_name,
	'1972-08-26'::date	AS birth_year,
	'Salisbury'			AS birth_city
);
```

### Таблица жанры (genre)
|Ключ|Наименование поля|
|-|-|
|PK	|genre_id
|	|genre_name
```SQL
DROP TABLE IF EXISTS genre; 

CREATE TABLE genre AS (
SELECT 
	'234'			AS genre_id,
	'Fiction'		AS genre_name
UNION ALL
SELECT 
	'345'			AS genre_id,
	'Surrealism'	AS genre_name
UNION ALL
SELECT 
	'456'			AS genre_id,
	'Mystery'		AS genre_name
);
```


