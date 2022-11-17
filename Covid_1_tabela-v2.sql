SELECT *
FROM PortfolioProject.dbo.coviddeaths




--SELECT *
--FROM PortfolioProject.dbo.covidvaccination
--ORDER BY 4 DESC

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.coviddeaths
ORDER BY 1,2

-- Lookimg at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, nullif(total_deaths,0)/CAST(nullif(total_cases,0)AS float)*100 AS '%Deaths' 
FROM PortfolioProject.dbo.coviddeaths
ORDER BY 1,2

-- Lookimg at Total Cases vs Population Poland

SELECT location, date, population, total_cases, total_deaths, nullif(total_cases,0)/CAST(nullif(population,0)AS float)*100 AS '%All2Population' 
FROM PortfolioProject.dbo.coviddeaths
WHERE location like 'poland'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS 'HighestInfectionCount',  MAX(nullif(total_cases,0)/CAST(nullif(population,0)AS float)*100) AS 'PopulationInfected'
FROM PortfolioProject.dbo.coviddeaths
GROUP BY location, population
ORDER BY PopulationInfected DESC

-- Showing Countries with Highest Deat Count per population

SELECT location, population, MAX(total_deaths) AS 'HighestDeathCount',  MAX(nullif(total_deaths,0)/CAST(nullif(population,0)AS float)*100) AS '%Death2Population'
FROM PortfolioProject.dbo.coviddeaths
WHERE location not IN ('world','High income', 'upper middle income', 'Europe', 'North America', 'Asia', 'Lower middle income', 'South America', 'European Union')
GROUP BY location, population
ORDER BY 'HighestDeathCount' DESC

-- Check stats by continent

SELECT location, MAX(total_deaths) AS 'HighestDeathCount'
FROM PortfolioProject.dbo.coviddeaths
WHERE location IN ('world','Europe', 'North America', 'Asia', 'South America', 'oceania')
GROUP BY location 
ORDER BY 'HighestDeathCount' DESC


-- Global numbers day by day deaths %

SELECT date, SUM(new_cases) AS new_cases, SUM(new_deaths) AS new_deaths, SUM(new_deaths)/CAST(SUM(new_cases)AS DECIMAL(12,0))*100 AS new_deatsvsnew_cases
FROM PortfolioProject.dbo.coviddeaths
GROUP BY date
HAVING date > '2020-01-22'
ORDER BY date ASC

-- Global numbers total deaths %

SELECT SUM(CAST(new_cases AS DECIMAL(12,0))) AS new_cases, SUM(CAST(new_deaths as DECIMAL(12,0))) AS new_deaths, 
	   SUM(CAST(new_deaths AS DECIMAL(12,0)))/
	   SUM(CAST(new_cases AS DECIMAL(12,0)))*100 as new_deatsvsnew_cases
FROM PortfolioProject.dbo.coviddeaths

-- JOINING TABLES

SELECT *
FROM PortfolioProject.dbo.coviddeaths AS dea
JOIN PortfolioProject.dbo.covidvaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.coviddeaths AS dea
JOIN PortfolioProject.dbo.covidvaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.coviddeaths AS dea
JOIN PortfolioProject.dbo.covidvaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (Nullif(RollingPeopleVaccinated,0)/Population)*100
FROM PopvsVac

-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.coviddeaths AS dea
JOIN PortfolioProject.dbo.covidvaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 

USE PortfolioProject
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.coviddeaths AS dea
JOIN PortfolioProject.dbo.covidvaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

-- SELECT FROM VIEW

SELECT *
FROM PercentPopulationVaccinated