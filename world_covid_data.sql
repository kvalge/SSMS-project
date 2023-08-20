SELECT * FROM [covid-deaths]
ORDER BY 3, 4


SELECT * FROM [covid-vaccinations] 
ORDER BY 3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [covid-deaths]
ORDER BY 1, 2


--Total cases vs population by country
SELECT location, population,
MAX(CONVERT(bigint, total_cases)) AS cases_in_total, 
MAX(CONVERT(bigint, total_cases))/population * 100 AS share_of_cases
FROM [covid-deaths]
GROUP BY location, population
ORDER BY share_of_cases DESC


--Total hospitalized patients vs population by country
SELECT location, population,
MAX(CONVERT(bigint, hosp_patients)) AS hosp_in_total, 
MAX(CONVERT(bigint, hosp_patients))/population * 100 AS share_of_hosp
FROM [covid-deaths]
GROUP BY location, population
ORDER BY share_of_hosp DESC


--Countries with highest death count compared to population
SELECT location, population, 
MAX(CAST(total_deaths as int)) AS total_deaths, 
MAX(CAST(total_deaths as int))/population*100 AS share_of_deaths
FROM [covid-deaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


--Continents with highest death count compared to population
SELECT location, SUM(population)/COUNT(population) AS population, 
MAX(CAST(total_deaths as int)) AS total_deaths, 
MAX(CAST(total_deaths as int))/population*100 AS share_of_deaths
FROM [covid-deaths]
WHERE location IN('Europe', 'North America', 'Oceania', 'Asia', 'Africa')
GROUP BY location, population
ORDER BY 4 DESC


--Highest death count compared to population by income
SELECT location, SUM(population)/COUNT(population), 
MAX(CAST(total_deaths as int)) AS total_deaths, 
MAX(CAST(total_deaths as int))/population*100 AS share_of_deaths
FROM [covid-deaths]
WHERE location LIKE '%income'
GROUP BY location, population
ORDER BY 4 DESC


--Deaths by date in the world
SELECT date, MAX(CAST(total_deaths as int))
FROM [covid-deaths]
GROUP BY date
ORDER BY  date


--Deaths by date by continent
SELECT date, location, MAX(CAST(total_deaths as int))
FROM [covid-deaths]
WHERE location IN('Europe', 'North America', 'Oceania', 'Asia', 'Africa')
GROUP BY date, location
ORDER BY location, date


--Total cases vs total deaths in Estonia per date
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/CONVERT(float, total_cases))*100 AS death_percentage
FROM [covid-deaths]
WHERE location = 'Estonia'
ORDER BY 2


--Cumulative total deaths vs population in Estonia
SELECT location, date, population, total_cases, total_deaths, (total_deaths/population)*100 AS death_percentage
FROM [covid-deaths]
WHERE location = 'Estonia'
ORDER BY 2


--Joining tables
SELECT *
FROM [covid-deaths] AS DEA
JOIN [covid-vaccinations] VAC
ON DEA.location = VAC.location AND DEA.date = VAC.date


SELECT DEA.location, DEA.population,
MAX(CAST(total_vaccinations as bigint)) AS total_vaccination,
MAX(CAST(total_vaccinations as bigint)) / DEA.population * 100 AS share
FROM [covid-deaths] AS DEA
JOIN [covid-vaccinations] VAC
ON DEA.location = VAC.location AND DEA.date = VAC.date
GROUP BY DEA.location, DEA.population
ORDER BY 4 DESC


SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS rolling_vaccination
FROM [covid-deaths] DEA
JOIN [covid-vaccinations] VAC
ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


--Rolling vaccination percentage

--CTE
WITH pop_vac(continent, location, date, population, new_vaccinations, rolling_vaccination)
AS(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) 
	AS rolling_vaccination
FROM [covid-deaths] DEA
JOIN [covid-vaccinations] VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)

SELECT *, rolling_vaccination/population*100 AS share
FROM pop_vac


--Temp table
DROP TABLE IF EXISTS #precent_vaccinated
CREATE TABLE #precent_vaccinated(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination numeric)

SELECT * FROM #precent_vaccinated

INSERT INTO #precent_vaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) 
	AS rolling_vaccination
FROM [covid-deaths] DEA
JOIN [covid-vaccinations] VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *, (rolling_vaccination/population)*100 AS share
FROM #precent_vaccinated


--view creation
DROP VIEW IF EXISTS vaccination_percent
CREATE VIEW vaccination AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) 
	AS rolling_vaccination
FROM [covid-deaths] DEA
JOIN [covid-vaccinations] VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL;

SELECT * FROM vaccination





