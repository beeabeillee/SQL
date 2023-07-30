--SQL Exploration Covid19 Jan 2020 - Jul 2023

SELECT *
FROM Portfolio_COVID19..CovidDeath

SELECT  DISTINCT continent, location
FROM Portfolio_COVID19..CovidDeath
WHERE continent <> location

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_COVID19..CovidDeath


--ALTER COLUMN" is a SQL statement used to modify the data type of an existing column in a table. 
--It is part of the "ALTER TABLE" statement, which allows you to make structural changes to a table.
-- Alter data type of total_deaths and total_cases from nvarchar to float
ALTER TABLE Portfolio_COVID19..CovidDeath
ALTER COLUMN total_deaths float 

ALTER TABLE Portfolio_COVID19..CovidDeath
ALTER COLUMN total_cases float

-- CAST" is an SQL function that allows you to convert data from one data type to another within a query. 
-- It is primarily used to perform explicit type conversion when retrieving or manipulating data in a SELECT statement
-- SELECT CAST (column_name AS new_data_type) FROM table_name

-- Total death percentage by total cases for each country 1st March 2020 vs 19th July 2023
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Portfolio_COVID19..CovidDeath
WHERE date = '2020-03-01' OR date > '2023-07-18'
ORDER BY location 

-- death_percentage over 1 percent at 2023-07-18 (data downloaded)
SELECT *
FROM (SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
  FROM Portfolio_COVID19..CovidDeath) AS inner_table
WHERE death_percentage >= 1 AND date > '2023-07-18'

-- Total case vs population: percentage of population get covid infection
SELECT location, date, total_cases, population, total_deaths, (total_cases/population)*100 AS infection_percentage
FROM Portfolio_COVID19..CovidDeath
WHERE date = '2020-03-01' OR date > '2023-07-18'
ORDER BY location 

-- Highest rate infection by country
SELECT location, MAX(total_cases) as highest_infection, population, MAX((total_cases/population)*100) AS population_infection_percentage
FROM Portfolio_COVID19..CovidDeath
GROUP BY location, population
ORDER BY population_infection_percentage DESC

-- Countries with highest death count per population
SELECT location, MAX(total_deaths) as highest_death, population, MAX((total_deaths/population)*100) AS population_death_percentage
FROM Portfolio_COVID19..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population_death_percentage DESC

-- Highest death by continent 
SELECT continent, date, MAX(total_deaths) as total_death_count
FROM Portfolio_COVID19..CovidDeath
WHERE continent IS NOT NULL AND date > '2023-07-18'
GROUP BY continent, date

-- Re-inspect dataset range date and new_cases daily
SELECT date, sum(new_cases)
FROM Portfolio_COVID19..CovidDeath
group by date
order by date


-- daily cases total globally 
SELECT date, SUM(new_cases) as daily_cases, SUM(new_deaths) as daily_death
FROM Portfolio_COVID19..CovidDeath
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date

-- Global numbers daily death percentage 
SELECT date, SUM(new_cases) as daily_cases, SUM(new_deaths) as daily_death, 
  SUM(new_deaths)/SUM(new_cases)*100 as daily_death_percentage
FROM Portfolio_COVID19..CovidDeath
WHERE continent IS NOT NULL AND new_cases <> 0 
GROUP BY date
ORDER BY date


--Global numbers new cases and new deaths in total
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, 
  SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
FROM Portfolio_COVID19..CovidDeath
WHERE continent IS NOT NULL AND new_cases <> 0 AND location NOT IN 
('Lower middle income','Asia','World','European Union','Oceania','South America','Africa','Low income','North America', 'Europe',
 'Upper middle income', 'High income' )

-- Checking duplicate entries
SELECT location, date, new_cases, COUNT(*)
FROM Portfolio_COVID19..CovidDeath
GROUP BY location, date, new_cases
HAVING COUNT(*) > 1


SELECT *
FROM Portfolio_COVID19..CovidVaccinations
ORDER BY location 

--Explore and Join 2 table
SELECT *
FROM Portfolio_COVID19..CovidDeath as death
JOIN Portfolio_COVID19..CovidVaccinations as vacc ON 
death.location = vacc.location AND death.date = vacc.date

SELECT death.location, death.date, total_cases, population, CAST (total_vaccinations as float) as total_vacc, 
 (total_cases/population)*100 as total_cases_percentage, (CAST (total_vaccinations as float)/population)*100 as total_vacc_percentage
FROM Portfolio_COVID19..CovidDeath as death
JOIN Portfolio_COVID19..CovidVaccinations as vacc ON 
death.location = vacc.location AND death.date = vacc.date
WHERE death.date > '2023-07-18'