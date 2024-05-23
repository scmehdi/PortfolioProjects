SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL and continent != ' '
ORDER BY 3, 4;

-- Looking at Total Cases vs Total Deaths, shows the likelyhood of dying if you contract covid in each country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looking at Total Cases vs Population 
SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentagePopulationInfected
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS HighestInfectionCont, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC;

-- Countries with highest Deaths count per population 
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) as TotalDeadCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeadCount DESC;

-- Let's break things down by continent 
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) as TotalDeadCount
FROM coviddeaths
WHERE continent IS NOT NULL AND continent != ''
GROUP BY continent
ORDER BY TotalDeadCount DESC;

-- Global Numbers 

SELECT STR_TO_DATE(date, '%m/%d/%Y') as new_date, SUM(new_cases) as total_cases, SUM(new_deaths)as total_deaths, SUM(new_deaths)/SUM(new_cases)*100
FROM coviddeaths
WHERE continent IS NOT NULL AND continent != ''
group by new_date
ORDER BY new_date, total_cases;

-- Total Population vs Vaccination
SELECT dea.continent, dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y'), dea.population, CAST(vac.new_vaccinations AS UNSIGNED)
, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION by dea.location ORDER by dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND STR_TO_DATE(dea.date, '%d/%m/%Y') = STR_TO_DATE(vac.date, '%d/%m/%Y')
WHERE dea.continent IS NOT NULL AND dea.continent != ''
ORDER BY  dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y');

-- USE CTE (we want to calculate the percentage of the population vaccinated but we can't use a column that we just created 
WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        STR_TO_DATE(dea.date, '%d/%m/%Y') AS date, 
        dea.population, 
        CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
            PARTITION BY dea.location 
            ORDER BY STR_TO_DATE(dea.date, '%d/%m/%Y')
        ) AS RollingPeopleVaccinated
    FROM 
        coviddeaths dea
    JOIN 
        covidvaccinations vac ON dea.location = vac.location
        AND STR_TO_DATE(dea.date, '%d/%m/%Y') = STR_TO_DATE(vac.date, '%d/%m/%Y')
    WHERE 
        dea.continent IS NOT NULL 
        AND dea.continent != ''
)
SELECT * 
, (RollingPeopleVaccinated/population)*100 AS rolling_vaccinated_percentage
FROM PopvsVac;

-- ORDER BY location, date;


-- TEMP TABLE 
-- Drop the temporary table if it exists
DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TEMPORARY TABLE PercentPopulationVaccinated 
(
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME, 
    population BIGINT,
    new_vaccinations BIGINT, 
    rolling_vaccinated_percentage INT
);

-- Insert data into the temporary table
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%d/%m/Y'), 
    dea.population, 
    CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations,
    (SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location 
        ORDER BY STR_TO_DATE(dea.date, '%d/%m/%Y')
    ) / dea.population) * 100 AS rolling_vaccinated_percentage
FROM 
    coviddeaths dea
JOIN 
    covidvaccinations vac ON dea.location = vac.location
    AND STR_TO_DATE(dea.date, '%d/%m/%Y') = STR_TO_DATE(vac.date, '%d/%m/%Y')
WHERE 
    dea.continent IS NOT NULL 
    AND dea.continent != '';

-- CREATE VIEW TO STORE DATA LATER FOR VIZ
CREATE VIEW  PopvsVac AS
 SELECT 
        dea.continent, 
        dea.location, 
        STR_TO_DATE(dea.date, '%d/%m/%Y') AS date, 
        dea.population, 
        CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
            PARTITION BY dea.location 
            ORDER BY STR_TO_DATE(dea.date, '%d/%m/%Y')
        ) AS RollingPeopleVaccinated
    FROM 
        coviddeaths dea
    JOIN 
        covidvaccinations vac ON dea.location = vac.location
        AND STR_TO_DATE(dea.date, '%d/%m/%Y') = STR_TO_DATE(vac.date, '%d/%m/%Y')
    WHERE 
        dea.continent IS NOT NULL 
        AND dea.continent != ''
;

SELECT *
FROM PopvsVac;