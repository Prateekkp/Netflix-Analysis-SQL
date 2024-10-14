# Netflix Data Analysis - 15 Business Problems and Solutions

This repository contains SQL queries that solve various business problems using the Netflix dataset. Below are the SQL queries for each business problem.

-- 1. Count the number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*) AS total_content
FROM 
    netflix
GROUP BY 
    type;


-- 2. Find the most common rating for movies and TV shows
SELECT 
    type, 
    rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM 
        netflix
    GROUP BY 
        type, rating
) AS t1
WHERE 
    ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM 
    netflix
WHERE 
    type = 'Movie' 
    AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(show_id) AS total_content
FROM 
    netflix
GROUP BY 
    new_country
ORDER BY 
    total_content DESC
LIMIT 5;


-- 5. Identify the longest movie
SELECT *
FROM 
    netflix
WHERE 
    type = 'Movie'
    AND duration = (SELECT MAX(duration) FROM netflix);


-- 6. Find content added in the last 5 years
SELECT *
FROM 
    netflix
WHERE 
    TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM 
    netflix
WHERE 
    director LIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM 
    netflix
WHERE 
    type = 'TV Show'
    AND SPLIT_PART(duration, ' ', 1)::numeric > 5;


-- 9. Count the number of content items in each genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genres,
    COUNT(show_id) AS total_content
FROM 
    netflix
GROUP BY 
    genres;


-- 10. Find each year and the average number of content released in India on Netflix
-- Return the top 5 years with the highest average content release
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS total_content,
    ROUND(COUNT(*)::numeric / 
          (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS avg_content_per_year
FROM 
    netflix
WHERE 
    country = 'India'
GROUP BY 
    year
ORDER BY 
    avg_content_per_year DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT *
FROM 
    netflix
WHERE 
    listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT *
FROM 
    netflix
WHERE 
    director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in the last 10 years
SELECT *
FROM 
    netflix
WHERE 
    cast LIKE '%Salman Khan%'
    AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(cast, ',')) AS actors,
    COUNT(*) AS total_content
FROM 
    netflix
WHERE 
    country ILIKE '%India%'
GROUP BY 
    actors
ORDER BY 
    total_content DESC
LIMIT 10;


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description
-- Label content as 'Bad' or 'Good', and count how many items fall into each category
WITH categorized_content AS (
    SELECT 
        *,
        CASE
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' 
            THEN 'Bad_Content'
            ELSE 'Good_Content'
        END AS category
    FROM 
        netflix
)
SELECT 
    category,
    COUNT(*) AS total_count
FROM 
    categorized_content
GROUP BY 
    category;
