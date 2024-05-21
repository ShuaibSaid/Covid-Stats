SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--Showing total
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Showing the percentage of deaths to infections
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Showing the hihgest percentage of infections to the population
SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases / population))*100 AS percent_of_population_infected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY 4 desc

--Showing the highest death counts per population
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

--Showing same as above but by continent
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%sweden%'
WHERE continent is null
GROUP BY location
ORDER BY total_death_count desc


--Showing global numbers
SELECT SUM(new_cases) AS total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
--GROUP BY date
ORDER BY 1,2



--CTE
WITH Population_vaccinated (continent, location, date, population, new_vaccinations, people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 AS people_vaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (people_vaccinated/population)*100 AS percentage_vaccinated
FROM Population_vaccinated


--TEMP TABLE
CREATE TABLE #Percent_of_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_vaccinated numeric
)

INSERT INTO #Percent_of_population_vaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 AS people_vaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


--Creating view for later
CREATE VIEW Percent_of_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 AS people_vaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null