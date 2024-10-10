-- SELECT * 
-- FROM PortofolioProject.coviddeaths
-- WHERE continent IS NOT NULL AND TRIM(continent) != ''
-- ORDER BY  3,4;

-- SELECT * 
-- FROM PortofolioProject.covidvaccinations
-- ORDER BY  3,4;

-- Select Data that we are going to be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject.coviddeaths
WHERE continent IS NOT NULL AND TRIM(continent) != ''
ORDER BY  1,2;

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of Dying if you contract in your country 
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject.coviddeaths
WHERE Location like '%states%' AND continent IS NOT NULL AND TRIM(continent) != ''
ORDER BY 1,2;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid
 
SELECT Location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM PortofolioProject.coviddeaths
WHERE continent IS NOT NULL AND TRIM(continent) != ''
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT Location,population, MAX(total_cases) as HighestInfectionCount,
 MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortofolioProject.coviddeaths
WHERE continent IS NOT NULL AND TRIM(continent) != ''
GROUP BY location,population
ORDER BY PercentPopulationInfected desc;

-- Showing Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as SIGNED )) as TotalDeathCount
FROM PortofolioProject.coviddeaths
WHERE continent IS NOT NULL AND TRIM(continent) != ''
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Let's breaks things down by continent

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as SIGNED )) as TotalDeathCount
FROM PortofolioProject.coviddeaths
WHERE continent IS NOT NULL AND TRIM(continent) != ''
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- Grobal Numbers 

SELECT SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,
 SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject.coviddeaths
-- WHERE Location like '%states%' AND 
WHERE continent IS NOT NULL AND TRIM(continent) != ''
-- GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations
-- Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations,RollinhgPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
as RollinhgPeopleVaccinated
--  
FROM PortofolioProject.coviddeaths dea 
JOIN PortofolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND TRIM(dea.continent) != ''
)
SELECT *, (RollinhgPeopleVaccinated/population)*100 
FROM PopvsVac;

-- TEMPT TABLE
DROP TEMPORARY TABLE IF exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortofolioProject.coviddeaths dea 
JOIN PortofolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND TRIM(dea.continent) != ''
ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PercentPopulationVaccinated;