-- Netflix Tv shows project

CREATE TABLE netflix
(
	show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
-- selecting complete data
SELECT * FROM netflix;

--count of total columns
SELECT 
	COUNT(*) as total_content
FROM netflix;

-- different types of shows
SELECT 
	DISTINCT (type)
FROM netflix;


1. Count the number of Movies vs TV Shows

SELECT type,
	COUNT(*) as cnt_dist_shows
FROM netflix
GROUP BY type;

	
2. Find the most common rating for movies and TV shows

SELECT type, rating
FROM
(
	SELECT type, rating, COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	from netflix
	GROUP BY 1, 2
	--ORDER BY 1, 3 DESC;
) AS t1
WHERE ranking = 1;


3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;


4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(show_id) AS total_cnt
	--RANK() OVER(PARTITION BY country GROUP BY country) AS country_rank
FROM netflix
GROUP BY new_country
ORDER BY total_cnt Desc
LIMIT 5;

		--SELECT   (for making the multiple countries in a row  to single country )
		--	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country 
		--FROM netflix;
			

5. Identify the longest movie

SELECT *
FROM netflix
WHERE type = 'Movie' 
	AND 
	duration = (SELECT MAX(duration) FROM netflix);


6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
	AND 
	SPLIT_PART(duration, ' ', 1)::numeric > 5;

	-- example for 'split_part'
	--SELECT
		--SPLIT_PART('APPLE BANANA CARROT BEETROOT', ' ', 1) 

9. Count the number of content items in each genre

SELECT  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(Show_id) AS total_content
FROM netflix
GROUP BY genre
	--ORDER BY total_content DESC;

10.Find each year and the average numbers of content release in India on netflix.
	--return top 5 year with highest avg content release!

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year, 
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2)
	AS avg_content_india	
FROM netflix
WHERE country = 'India'
GROUP BY year;

11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

12. Find all content without a director

SELECT *
FROM netflix
WHERE director IS NULL;

	
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
where casts ILIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

	
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10;

15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
SELECT *,
	CASE 
	WHEN
		description ILIKE '%kill%'
		OR
		description ILIKE '%violence%'
		THEN 'Bad Content'
		ELSE 'Good Content'
	END  category
FROM netflix
)
SELECT category, COUNT(*) AS table_content
FROM new_table
GROUP BY category;
