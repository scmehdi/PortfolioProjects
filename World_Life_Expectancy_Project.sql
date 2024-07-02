# Data Cleaning 

SELECT *
FROM worldlifexpectancy;

SELECT country, year, CONCAT(Country, year), count(CONCAT(Country, year))
FROM worldlifexpectancy_backup
GROUP BY country, year, CONCAT(Country, year)
HAVING COUNT(CONCAT(Country, year)) > 1;

SELECT *
FROM (
SELECT row_id, 
CONCAT(Country, year), 
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, year) ORDER BY CONCAT(Country, year)) AS row_num
FROM worldlifexpectancy
) AS row_table
WHERE row_num > 1;

DELETE FROM worldlifexpectancy
WHERE row_id IN 
( 
SELECT row_id
FROM (
SELECT row_id, 
CONCAT(Country, year), 
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, year) ORDER BY CONCAT(Country, year)) AS row_num
FROM worldlifexpectancy
) AS row_table
WHERE row_num > 1
);

SELECT *
FROM worldlifexpectancy
WHERE status = '';

SELECT DISTINCT(status)
FROM worldlifexpectancy
WHERE status <> '';

SELECT DISTINCT(country)
FROM worldlifexpectancy
WHERE status ='Developing';

UPDATE worldlifexpectancy t1 
JOIN  worldlifexpectancy t2
ON t1.country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing'
;

SELECT *
FROM worldlifexpectancy
WHERE country = 'United States of America';

UPDATE worldlifexpectancy t1 
JOIN  worldlifexpectancy t2
ON t1.country = t2.country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developed'
;

SELECT t1.country, t1.year, t1.Lifeexpectancy,
t2.country, t2.year, t2.Lifeexpectancy,
t3.country, t3.year, t3.Lifeexpectancy,
ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2, 1) 
FROM worldlifexpectancy t1
JOIN worldlifexpectancy t2
ON t1.country = t2.country
AND t1.year = t2.year - 1
JOIN worldlifexpectancy t3
ON t1.country = t3.country
AND t1.year = t3.year +1 
WHERE t1.Lifeexpectancy = ''
;

UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2
ON t1.country = t2.country
AND t1.year = t2.year - 1
JOIN worldlifexpectancy t3
ON t1.country = t3.country
AND t1.year = t3.year +1 
SET t1.Lifeexpectancy = ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2, 1) 
WHERE t1.Lifeexpectancy = ''
;

SELECT *
FROM worldlifexpectancy;

# Exploratory Data Analysis 

SELECT Country, MIN(Lifeexpectancy), MAX(Lifeexpectancy),
ROUND(MAX(Lifeexpectancy) - MIN(Lifeexpectancy), 1) AS life_increase_15_years
FROM worldlifexpectancy
GROUP BY Country
HAVING MIN(Lifeexpectancy) <> 0 AND MIN(Lifeexpectancy) <> 0
ORDER BY life_increase_15_years ;

SELECT Year, ROUND(AVG(Lifeexpectancy), 1)
FROM worldlifexpectancy
WHERE Lifeexpectancy <> 0
GROUP BY Year
ORDER BY year;

# CORRELATION GDP to Life Expectancy
SELECT Country, 
ROUND(AVG(Lifeexpectancy), 1) AS Life_Exp, 
ROUND(AVG(GDP), 1) AS GDP
FROM worldlifexpectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC;

SELECT 
SUM(CASE 
WHEN GDP >= 1500 THEN 1 ELSE 0
END) high_GDP_count,
ROUND(AVG(CASE 
WHEN GDP >= 1500 THEN Lifeexpectancy ELSE NULL
END), 1) high_GDP_life_expectancy,
SUM(CASE 
WHEN GDP <= 1500 THEN 1 ELSE 0
END) low_GDP_count,
ROUND(AVG(CASE 
WHEN GDP <= 1500 THEN Lifeexpectancy ELSE NULL
END), 1) low_GDP_life_expectancy
FROM worldlifexpectancy;

SELECT status, ROUND(AVG(Lifeexpectancy), 1), COUNT(DISTINCT Country)
FROM worldlifexpectancy
GROUP BY status;

SELECT country, ROUND(AVG(Lifeexpectancy), 1) AS life_exp, ROUND(AVG(BMI), 1) AS BMI
FROM worldlifexpectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC;

SELECT Country, 
Year, 
Lifeexpectancy,
AdultMortality, 
SUM(AdultMortality) OVER(PARTITION BY Country ORDER BY Year) AS rolling_total
FROM worldlifexpectancy; 