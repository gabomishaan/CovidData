USE CovidData;

--First look at the data
SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3, 4;


--SELECT THE DATA TO BE USED
SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM 
	CovidDeaths
WHERE continent is not null
ORDER BY Location, date;

--Analyzing Total Cases vs Total Deaths
--Likelihood of death when infected per country (looking at the US)
SELECT 
	Location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases)*100, 5) AS DeathPercentage
FROM 
	CovidDeaths
WHERE
	Location like '%states' AND continent is not NULL
ORDER BY Location, date;

--Analyzing total cases vs population
SELECT 
	Location, date, population, total_cases,  ROUND((total_cases / population)*100, 5) AS PercentOfPopulationInfected
FROM 
	CovidDeaths
WHERE continent is not null
ORDER BY Location, date;

--Showing countries with Highest Infection  to Population Ratio
SELECT 
	Location,  population, MAX(total_cases) as HighestInfectionCount,  ROUND(MAX((total_cases / population))*100, 5) AS MaxPercentOfPopulationInfected
FROM 
	CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY MaxPercentOfPopulationInfected DESC;

--Showing countries with Highest Death Count per Population 
SELECT 
	Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM 
	CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Showing the data broken down by continent
--Showing the continents with highest deathcount
SELECT 
	location AS 'Continent', MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM 
	CovidDeaths
WHERE continent is null AND location not in ('World', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC; 

--Global numbers
SELECT 
	 SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 6) AS deathPercentage
FROM 
	CovidDeaths
WHERE
	continent is not NULL
--GROUP BY date
ORDER BY 1, 2;


--Looking at total population vs vaccination

SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) 
		OVER (PARTITION BY 
		dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea 
	JOIN
	CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated) 
AS 
(
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) 
		OVER (PARTITION BY 
		dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea 
	JOIN
	CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) 
		OVER (PARTITION BY 
		dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea 
	JOIN
	CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date;
--WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) 
		OVER (PARTITION BY 
		dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea 
	JOIN
	CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated




