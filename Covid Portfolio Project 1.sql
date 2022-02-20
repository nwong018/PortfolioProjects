
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT 
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS 'DeathPercentage'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT 
  location,
  date,
  population,
  total_cases,
  (total_cases/Population)*100 AS 'PercentPopulationInfected'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT 
  location,
  population,
  Max(total_cases) AS HighestInfectionCount,
  (Max(total_cases)/Population)*100 AS 'PercentPopulationInfected'
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC --Not possible in MySQL?


-- Shows Countries with Highest Death Count per Population

SELECT 
  location,
  MAX(CAST(total_deaths AS int)) AS TotalDeathCount -- CAST because issues with data type
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null -- removed continents from location
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking things down by continent

SELECT 
  continent,
  MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Shows continents with the highest death count per population

SELECT 
  continent,
  MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMEBRS

SELECT 
  
  date,
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths AS int)) AS total_deaths,
  SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS 'DeathPercentage'
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2



--Looking at Total Population vs Vaccinations

SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea. population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea. population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated -- allows you to recreate the table
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert #PercentPopulationVaccinated
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  vac.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population) AS NumberofDosestoPopulation
FROM #PercentPopulationVaccinated



--Creating View to store data for later visulizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  vac.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3


Select *   
FROM PercentPopulationVaccinated