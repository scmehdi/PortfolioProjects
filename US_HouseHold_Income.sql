SELECT *
FROM USHouseholdIncome;

SELECT id, count(id)
FROM USHouseholdIncome
Group BY id 
HAVING COUNT(id) > 1;

# Identify Duplicates 
SELECT *
FROM (
SELECT row_id, 
id, 
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM USHouseholdIncome
) duplicates
WHERE row_num > 1
;
# Removing Duplicates
DELETE FROM USHouseholdIncome
WHERE row_id IN (
SELECT row_id
FROM (
SELECT row_id, 
id, 
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM USHouseholdIncome
) duplicates
WHERE row_num > 1)
;

# Idenifty Duplicates 
SELECT id, count(id)
FROM ushouseholdincome_statistics
Group BY id 
HAVING COUNT(id) > 1;

SELECT state_name, count(state_name)
FROM USHouseholdIncome
GROUP BY state_name; 

UPDATE USHouseholdIncome
SET State_name = 'Georgia'
WHERE state_name = 'georia'; 

UPDATE USHouseholdIncome
SET state_name = 'Alabama'
WHERE state_name = 'alabama';

SELECT *
FROM USHouseholdIncome
WHERE county = 'Autauga County' 
ORDER BY 1;

SELECT DISTINCT state_ab 
FROM USHouseholdIncome
ORDER BY 1;

UPDATE USHouseholdIncome
SET Place = 'Autaugaville'
WHERE county = 'Autauga County' AND city = 'Vinemont';

SELECT type, count(type)
FROM USHouseholdIncome
GROUP BY type;

UPDATE USHouseholdIncome
SET type = 'Borough'
WHERE type = 'Boroughs';

SELECT DISTINCT(awater)
FROM  USHouseholdIncome
WHERE awater = 0 OR awater IS NULL or awater = '';

# Exploratory Data Analysis
SELECT State_name, SUM(Aland), Sum(Awater)
FROM USHouseholdIncome
GROUP BY State_name
ORDER BY 2;

SELECT u.state_name, ROUND(avg(mean), 1), ROUND(avg(median), 1)
FROM USHouseholdIncome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.state_name
ORDER BY 2 DESC
LIMIT 10;

SELECT Type, COUNT(TYPE), ROUND(avg(mean), 1), ROUND(avg(median), 1)
FROM USHouseholdIncome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
WHERE Mean <> 0
GROUP BY type
HAVING count(type) > 100
ORDER BY 4 DESC;

SELECT *
FROM USHouseholdIncome
WHERE Type = 'Community';

SELECT u.state_name, city, ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM USHouseholdIncome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
GROUP BY u.state_name, city
ORDER BY 3 DESC
LIMIT 10;

