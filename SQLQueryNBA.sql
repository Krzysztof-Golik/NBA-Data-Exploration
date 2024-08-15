--Loading the data set
Select*
From PortfolioProject..all_seasons


Alter table PortfolioProject..all_seasons
drop column [Column 0]

--Number of players from every country

Select distinct (country), count(country) PlayersPerCountry
From PortfolioProject..all_seasons
group by country
order by 2 desc




SELECT player_name, country
FROM (
    SELECT 
        player_name, 
        country,
        ROW_NUMBER() OVER (PARTITION BY player_name ORDER BY player_name) AS rn
    FROM 
        PortfolioProject..all_seasons
) subquery
WHERE rn = 1;

SELECT country, COUNT(player_name) AS player_count
FROM (
    SELECT 
        player_name, 
        country,
        ROW_NUMBER() OVER (PARTITION BY player_name ORDER BY player_name) AS rn
    FROM 
        PortfolioProject..all_seasons
) subquery
WHERE rn = 1
GROUP BY country
ORDER BY player_count DESC;



Select *
FROM PortfolioProject..all_seasons

--

--Players from Poland
Select *
FROM PortfolioProject..all_seasons
Where country = 'Poland'

--Finding players with highest career ppg

SELECT *
FROM PortfolioProject..all_seasons

WITH unique_players AS (
    SELECT 
        player_name, 
        ROW_NUMBER() OVER (PARTITION BY player_name ORDER BY player_name) AS rn
    FROM 
        PortfolioProject..all_seasons
)
SELECT player_name, AVG(CAST(pts AS FLOAT)) AS average_pts
FROM PortfolioProject..all_seasons
WHERE player_name IN (
    SELECT player_name
    FROM unique_players
    WHERE rn = 1
)
GROUP BY player_name
ORDER BY average_pts DESC;

--

Select*
FROM PortfolioProject..all_seasons
Where player_name = 'Ivan Rabb'

--Deleting an error in the data set

DELETE FROM PortfolioProject..all_seasons
WHERE player_name = 'Ivan Rabb'

--Finding players with highest career rpg

WITH unique_players AS (
    SELECT 
        player_name, 
        ROW_NUMBER() OVER (PARTITION BY player_name ORDER BY player_name) AS rn
    FROM 
        PortfolioProject..all_seasons
)
SELECT player_name, AVG(CAST(reb AS FLOAT)) AS average_reb
FROM PortfolioProject..all_seasons
WHERE player_name IN (
    SELECT player_name
    FROM unique_players
    WHERE rn = 1
)
GROUP BY player_name
ORDER BY average_reb DESC;

--

Select*
FROM PortfolioProject..all_seasons

--Finding players with highest career apg

WITH unique_players AS (
    SELECT 
        player_name, 
        ROW_NUMBER() OVER (PARTITION BY player_name ORDER BY player_name) AS rn
    FROM 
        PortfolioProject..all_seasons
)
SELECT player_name, AVG(CAST(ast AS FLOAT)) AS average_ast
FROM PortfolioProject..all_seasons
WHERE player_name IN (
    SELECT player_name
    FROM unique_players
    WHERE rn = 1
)
GROUP BY player_name
ORDER BY average_ast DESC;

-- Checking if there is a correlation between age of the player and amount of points he is averaging

WITH stats AS (
    SELECT 
        CAST(age AS FLOAT) AS age,
        CAST(pts AS FLOAT) AS pts,
        COUNT(*) OVER() AS n,
        SUM(CAST(age AS FLOAT)) OVER() AS sum_x,
        SUM(CAST(pts AS FLOAT)) OVER() AS sum_y,
        SUM(CAST(age AS FLOAT) * CAST(pts AS FLOAT)) OVER() AS sum_xy,
        SUM(CAST(age AS FLOAT) * CAST(age AS FLOAT)) OVER() AS sum_xx,
        SUM(CAST(pts AS FLOAT) * CAST(pts AS FLOAT)) OVER() AS sum_yy
    FROM 
        PortfolioProject..all_seasons
),
correlation AS (
    SELECT 
        n,
        sum_x,
        sum_y,
        sum_xy,
        sum_xx,
        sum_yy,
        (n * sum_xy - sum_x * sum_y) / 
        (SQRT((n * sum_xx - sum_x * sum_x) * (n * sum_yy - sum_y * sum_y))) AS corr_coeff
    FROM 
        stats
)
SELECT 
    corr_coeff
FROM 
    correlation;


---Picking the most optimal age for a basketball player when he might be on the peak of his career based on pts, reb, ast and net_rating

WITH age_stats AS (
    SELECT 
        age,
        AVG(CAST(pts AS FLOAT)) AS avg_pts,
        AVG(CAST(reb AS FLOAT)) AS avg_reb,
        AVG(CAST(ast AS FLOAT)) AS avg_ast,
        AVG(CAST(net_rating AS FLOAT)) AS avg_net_rating
    FROM 
        PortfolioProject..all_seasons
    GROUP BY 
        age
),
normalized_stats AS (
    SELECT 
        age,
        avg_pts,
        avg_reb,
        avg_ast,
        avg_net_rating,
        (avg_pts - MIN(avg_pts) OVER()) / (MAX(avg_pts) OVER() - MIN(avg_pts) OVER()) AS norm_pts,
        (avg_reb - MIN(avg_reb) OVER()) / (MAX(avg_reb) OVER() - MIN(avg_reb) OVER()) AS norm_reb,
        (avg_ast - MIN(avg_ast) OVER()) / (MAX(avg_ast) OVER() - MIN(avg_ast) OVER()) AS norm_ast,
        (avg_net_rating - MIN(avg_net_rating) OVER()) / (MAX(avg_net_rating) OVER() - MIN(avg_net_rating) OVER()) AS norm_net_rating
    FROM 
        age_stats
),
composite_score AS (
    SELECT 
        age,
        norm_pts,
        norm_reb,
        norm_ast,
        norm_net_rating,
        (0.4 * norm_pts + 0.3 * norm_reb + 0.2 * norm_ast + 0.1 * norm_net_rating) AS comp_score
    FROM 
        normalized_stats
)
SELECT TOP 10
    age, 
    comp_score
FROM 
    composite_score
ORDER BY 
    comp_score DESC;

