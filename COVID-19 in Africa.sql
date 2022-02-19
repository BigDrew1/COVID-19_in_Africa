/*
COVID-19 in Africa

This data exploration was carried out using Microsoft SSMS

Skills used: Calculations with Operators, Converting data types, Agreggate functions, Windows functions,
			 Joins, CTE's, Temp Tables, Creating views

*/

--Viewing data in CovidDeaths

SELECT *
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'
ORDER BY location


--Viewing data in CovidVaccinations

SELECT *
FROM COVID_19_in_Africa..CovidVaccination
WHERE continent = 'Africa'
ORDER BY location


-- Selcting data to work with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'
ORDER BY location


--Finding the likelihood of dying from COVID-19 in Africa (death_percentage)

SELECT location, date total_cases, new_cases, total_deaths
, (total_deaths/total_cases) * 100 AS death_percentage
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'
ORDER BY location


--Finding the percentage of population infected with COVID-19 in Africa (percentage_of_population_infected)

SELECT location, date, population, total_cases
,(total_cases/population) * 100 AS percentage_of_population_infected
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'
ORDER BY location


--Looking at the countries in Africa with the Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count
,  Max((total_cases/population))*100 AS percentage_of_population_infected
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'
GROUP BY Location, Population
ORDER BY percentage_of_population_infected DESC


--Looking at the countries in Africa with the Highest Death Count per Population (Total_Death_Count)

SELECT Location, MAX(population) AS population, MAX(cast(Total_deaths AS INT)) AS Total_Death_Count
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'
GROUP BY Location
ORDER BY Total_Death_Count DESC

--Looking at the Death_percentage by countries

SELECT Location, MAX(population) AS population, MAX(cast(Total_deaths AS INT)) AS Total_Death_Count
, (MAX(cast(Total_deaths AS INT))/MAX(population)) * 100 AS Death_percentage
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'
GROUP BY Location
ORDER BY Total_Death_Count DESC


-- Taking a look at the total number of cases and deaths in Africa

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths
, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM COVID_19_in_Africa..CovidDeaths
WHERE continent = 'Africa'

-- Looking at the count of Population that has recieved at least one Covid Vaccine (Count_of_people_vaccinated)

SELECT Death.location, Death.date, Death.population,Vaccine.new_vaccinations
,SUM(CAST(Vaccine.new_vaccinations AS INT)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Count_of_people_vaccinated
FROM COVID_19_in_Africa..CovidDeaths Death
JOIN COVID_19_in_Africa..CovidVaccination Vaccine
	ON Death.location = Vaccine.location
	AND Death.date = Vaccine.date
WHERE death.continent = 'Africa'
ORDER BY location

-- Using CTE to perform Calculation on PARTITION BY in previous query (Percentage_of_vaccinated_Population)

WITH Count_Vac (Location, Date, Population, New_Vaccinations, Count_of_people_vaccinated)
AS
(
SELECT Death.location, Death.date, Death.population,Vaccine.new_vaccinations
,SUM(CAST(Vaccine.new_vaccinations AS BIGINT)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Count_of_people_vaccinated
FROM COVID_19_in_Africa..CovidDeaths Death
JOIN COVID_19_in_Africa..CovidVaccination Vaccine
	ON Death.location = Vaccine.location
	AND Death.date = Vaccine.date
WHERE death.continent = 'Africa'
)
SELECT *, (Count_of_people_vaccinated/Population)*100 AS Percentage_of_vaccinated_Population
FROM Count_Vac


--Using Temp Table to perform Calculation on PARTITION BY in previous query

CREATE TABLE #Percent_Population_Vaccinated
(
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Count_of_people_vaccinated numeric
)
INSERT INTO #Percent_Population_Vaccinated
SELECT Death.location, Death.date, Death.population,Vaccine.new_vaccinations
,SUM(CAST(Vaccine.new_vaccinations AS BIGINT)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Count_of_people_vaccinated
FROM COVID_19_in_Africa..CovidDeaths Death
JOIN COVID_19_in_Africa..CovidVaccination Vaccine
	ON Death.location = Vaccine.location
	AND Death.date = Vaccine.date
WHERE death.continent = 'Africa'

SELECT *, (Count_of_people_vaccinated/Population)*100 AS Percentage_of_vaccinated_Population
FROM #Percent_Population_Vaccinated

-- Creating View to store data for Visualizations
GO 
CREATE VIEW Percent_Population_Vaccinated AS
SELECT Death.location, Death.date, Death.population,Vaccine.new_vaccinations
,SUM(CAST(Vaccine.new_vaccinations AS BIGINT)) 
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Count_of_people_vaccinated
FROM COVID_19_in_Africa..CovidDeaths Death
JOIN COVID_19_in_Africa..CovidVaccination Vaccine
	ON Death.location = Vaccine.location
	AND Death.date = Vaccine.date
WHERE death.continent = 'Africa'
