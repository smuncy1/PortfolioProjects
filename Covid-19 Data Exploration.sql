SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER By 1,2


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER By 1,2


SELECT Location, date, population, total_cases, (total_cases/population)*100 as percent_infected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER By 1,2


SELECT Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population))*100 as percent_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY population, location
ORDER By percent_infected desc



SELECT Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER By TotalDeathCount desc



SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER By TotalDeathCount desc


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

--Using a CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccines as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


--Using a temp table

DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
bew_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccines as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccines as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null