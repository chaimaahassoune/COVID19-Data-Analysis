
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select the data that i am going to use 
SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total cases and total deaths
-- the Death Percentage in Morocco
SELECT location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like 'Morocco' and  continent is not null
ORDER BY 1,2

-- using CTE 
WITH TotalCasesDeaths AS (
    -- Simplified and reordered the query for better readability
    SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
    FROM PortfolioProject..CovidDeaths
    WHERE continent IS NOT NULL
)
SELECT *
FROM TotalCasesDeaths 
WHERE location like 'Morocco';

-- Total cases vs Population
--  the Percent of Population Infected in morocco 
SELECT location,date,population ,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like 'Morocco' and  continent is not null
ORDER BY 1,2

-- using CTE 
-- Total cases vs Population, Percent of Population Infected in Morocco USING CTE 
WITH PopulationVsCases AS (
SELECT location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Morocco' AND continent IS NOT NULL -- Changed 'LIKE' to '=' for precise match
)
select * from PopulationVsCases


-- Countries with Highest Infection Rate compared to the Percent of  Population Infected
SELECT location,population ,MAX(total_cases)AS HighestInfection, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC 

-- using CTE 
-- Countries with Highest Infection Rate compared to the Percent of Population Infected
WITH InfectionRate AS (
SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location, population
)
SELECT * from InfectionRate 
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
SELECT location,MAX(total_deaths)AS HighestDeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY HighestDeathCount DESC 

-- continent with tha highest death count

SELECT continent,MAX(total_deaths)AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not  null -- ther is world also so we should exclude it 
GROUP BY continent 
ORDER BY HighestDeathCount DESC 


--Calculat numbers-- Calculate total cases, total deaths, and death percentage
SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_cases;

-- using view to Calculate total cases, total deaths, and death percentage
CREATE VIEW CovidStatsView AS
SELECT date,SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date;
-- the SELECT statement 
SELECT * FROM CovidStatsView ORDER BY date, total_cases;

-- Total Population vs Vaccinations

SELECT cd.continent, cd.location, cd.date,cv.new_vaccinations , 
SUM(cv.new_vaccinations)  OVER (partition BY cd.location ORDER BY cd.location , cd.date) as total_vaccination 
FROM PortfolioProject..CovidVaccinations cv
JOIN PortfolioProject..CovidDeaths cd
 ON cv.date=cd.date
  and cv.location = cd.location
WHERE cd.continent is not null
  order by 2,3 

  

--USING CTE to combine data from CovidVaccinations and CovidDeaths tables
WITH popVsvac (continent,location,date,population,new_vaccination,total_vaccination)
AS (
SELECT dea.continent, dea.location,dea.date,population,vac.new_vaccinations , 
-- Calculating the total vaccination over time for each location
SUM(vac.new_vaccinations)  OVER (partition BY dea.location ORDER BY dea.location , dea.date) as total_vaccination 
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
 ON vac.date=dea.date
  and vac.location =dea.location
WHERE dea.continent is not null
)
-- Selecting columns from the CTE and calculating the percentage of population vaccinated
SELECT *,(total_vaccination/population)*100 as  PercentagVacOnPup
FROM popVsvac
-- Ordering the results by the percentage of population vaccinated in descending order
ORDER BY 7 DESC 


-- USING Temp Table
--calculates the total vaccination for each location over time 
--and then computes the percentage of the population vaccinated for each location.
DROP TABLE if exists #percentepopulationvaccinated
CREATE TABLE #percentepopulationvaccinated
( continent nvarchar(50),
location nvarchar(50),
date date ,
population int,
new_vaccination numeric ,
total_vaccination numeric
)
INSERT INTO #percentepopulationvaccinated
 SELECT dea.continent, dea.location,dea.date,population,vac.new_vaccinations , 
SUM(vac.new_vaccinations)  OVER (partition BY dea.location ORDER BY dea.location , dea.date) as total_vaccination 
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
 ON vac.date=dea.date
  and vac.location =dea.location
WHERE dea.continent is not null

SELECT *,(total_vaccination/population)*100 AS percentagPpulationVaccinated
FROM #percentepopulationvaccinated


-- Calculating the total vaccination over time for each location
CREATE VIEW percentepopulationvaccinated AS 
SELECT dea.continent, dea.location,dea.date,population,vac.new_vaccinations , 
SUM(vac.new_vaccinations)  OVER (partition BY dea.location ORDER BY dea.location , dea.date) as total_vaccination 
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
 ON vac.date=dea.date
  and vac.location =dea.location
WHERE dea.continent is not null


SELECT * FROM percentepopulationvaccinated


