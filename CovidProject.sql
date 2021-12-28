SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select data that will be used

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths 
WHERE continent IS NOT NULL
order by 1,2


-- Looking at Total Cases versus Total Deaths (%)
-- Shows likelihood of dying from Covid in specified country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS [DeathPercentage]
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
order by 1,2

-- Looking at the Total Cases versus Population
-- Shows what percentage of population got Covid
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS [CasesPercentage]
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
order by 1,2


-- Looking at Countrues with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as [HighestInfectionCount], MAX((total_cases/population))*100 AS [CasesPercentage]
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
order by 4 desc

-- Loking at Countries with Highest Mortality Rate compared to Population
-- Total Deaths cast as integer to complete aggregate function
SELECT location, population, MAX(cast(total_deaths as int)) as [HighestMortalityCount], MAX((total_deaths/population))*100 AS [DeathPercentage]
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
order by HighestMortalityCount desc

--Break down by Location
SELECT location, MAX(cast(total_deaths as int)) as [HighestMortalityCount]
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
order by HighestMortalityCount desc


--Break down by CONTINENT
--INCORRECT WAY DOES NOT AGGREGATE PROPER CONTINENT DATA
SELECT continent, MAX(cast(total_deaths as int)) as [HighestMortalityCount]
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
order by HighestMortalityCount desc

--CORRECT breakdown by continent
-- Showing the Continents with the highest death counts per population
SELECT location, MAX(cast(total_deaths as int)) as [HighestMortalityCount]
FROM [Portfolio Project]..CovidDeaths
WHERE location IN ('World', 'Europe', 'North America', 'European Union', 'South America', 'Asia', 'Africa', 'Oceania', 'International')
GROUP BY location
order by HighestMortalityCount desc


-- Global data breakdown
-- Breakdwon by day
SELECT date, SUM(new_cases) AS [TotalCases], SUM(cast(new_deaths as int)) AS [TotalDeaths], ( SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS [MortalityRate]
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2


-- Total Data
SELECT SUM(new_cases) AS [TotalCases], SUM(cast(new_deaths as int)) AS [TotalDeaths], ( SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS [MortalityRate]
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2



--Second Data Table Covid Vaccination Data
SELECT *
FROM [Portfolio Project]..CovidVaccinations


WITH PopvsVac (Continent, location, date, population, RollingVaccinatedCount)
AS

--Combine both data sets on locaion and date columns
--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinatedCount
FROM [Portfolio Project]..CovidDeaths AS Dea
JOIN [Portfolio Project]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
order by 2,3


-- USE CT to show population vaccinated percentage as a rolling column
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingVaccinatedCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinatedCount
FROM [Portfolio Project]..CovidDeaths AS Dea
JOIN [Portfolio Project]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, (RollingVaccinatedCount/population)*100 AS [PopulationVaccinatedPercentage]
FROM PopvsVac



--Alternate Way
-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedCount numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinatedCount
FROM [Portfolio Project]..CovidDeaths AS Dea
JOIN [Portfolio Project]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *, (RollingVaccinatedCount/population)*100 AS [PopulationVaccinatedPercentage]
FROM #PercentPopulationVaccinated



-- Create View to store data for later visulizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinatedCount
FROM [Portfolio Project]..CovidDeaths AS Dea
JOIN [Portfolio Project]..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT * 
FROM PercentPopulationVaccinated


