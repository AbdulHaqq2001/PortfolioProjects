/*SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;*/



-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases,total_deaths,Round((total_deaths/total_cases)*100, 3) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Asia'
ORDER BY 1,2;

-- Looking at Total Cases vs Population

SELECT Location, date, Population, total_cases,Round((total_cases/population)*100, 3) AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Asia'
ORDER BY 2 DESC;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, Max(Round((total_cases/population)*100, 3)) AS CasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Asia'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY CasesPercentage DESC;


-- Showing Countries with Highest Death Count per Population


SELECT Location, MAX(Cast(total_deaths AS int)) AS HighestDeatchCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Asia'
Where continent is not NULL
GROUP BY location
ORDER BY HighestDeatchCount DESC;

-- Showing Continents


SELECT continent, MAX(Cast(total_deaths AS int)) AS HighestDeatchCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Asia'
Where continent is not NULL
GROUP BY continent
ORDER BY HighestDeatchCount DESC;


-- GLOBAL NUMBERS
SELECT 
	SUM(new_cases)									AS total_cases,
	SUM(cast(new_deaths as int))					AS total_cases,
	ROUND((SUM(CAST(new_deaths as int))/sum(new_cases)*100), 3) AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
-- GROUP BY date
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations


SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location
	ORDER BY dea.Location, dea.Date) AS TotalVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
	--AND TotalVac IS NOT NULL
ORDER BY 2,3;


-- USE CTE
WITH PopvsVac AS (
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location
	ORDER BY dea.Location, dea.Date) AS TotalVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
	--AND TotalVac IS NOT NULL
)
SELECT *,
	ROUND((TotalVac/population*100), 5) AS VacVSpop
FROM PopvsVac;
--WHERE TotalVac IS NOT NULL;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVac numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location
	ORDER BY dea.Location, dea.Date) AS TotalVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
SELECT *,
	ROUND((TotalVac/population*100), 5) AS VacVSpop
FROM #PercentPopulationVaccinated;
	
-- Creating View


CREATE VIEW
	PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location
	ORDER BY dea.Location, dea.Date) AS TotalVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
	--AND TotalVac IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;
















































