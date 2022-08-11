SELECT * 
FROM Portfolio_Project.coviddeaths
WHERE continent !=''
ORDER BY 3,4 ASC;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio_Project.coviddeaths
WHERE continent !=''
ORDER BY 1,2 ;

-- Total cases Vs Total Death
-- shows what percentage of people died having covid
SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project.coviddeaths
WHERE location like '%states%' AND  continent !=''
ORDER BY 1,2 ASC;

-- Total cases Vs Population
-- What percentage of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as PopulationPercent
FROM Portfolio_Project.coviddeaths 
WHERE location like '%states%' AND  continent !=''

ORDER BY 1,2 ASC;

-- which country has highest infection rate compared to population
SELECT location,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
FROM Portfolio_Project.coviddeaths
WHERE continent !=''
GROUP BY location,population
ORDER BY 3 DESC;

-- Showing the countries with the highest death count per country
SELECT location,MAX(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM Portfolio_Project.coviddeaths
WHERE continent !=''
GROUP BY location,population
ORDER BY 2 DESC;

-- Breaking down by continent
SELECT continent,MAX(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM Portfolio_Project.coviddeaths
WHERE continent !=''
GROUP BY continent 
ORDER BY 2 DESC;

-- Showing the continents with the highest death count per population
SELECT continent,MAX(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM Portfolio_Project.coviddeaths
WHERE continent !=''
GROUP BY continent
ORDER BY 2 DESC;

-- Global numbers
SELECT date,MAX(new_cases) as total_cases,SUM(cast(new_deaths as SIGNED)) as total_deaths,
SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 as DeathPercent
FROM Portfolio_Project.coviddeaths
WHERE continent !=''
GROUP BY date
ORDER BY 1,2 ASC;


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM Portfolio_Project.coviddeaths as dea
JOIN Portfolio_Project.covidvaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Looking at total population Vs Vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.coviddeaths as dea
JOIN Portfolio_Project.covidvaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Use CTE
WITH PopVsVac(continent,location,date,population,new_vaccinations,rollingPeopleVaccinated)
as(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.coviddeaths as dea
JOIN Portfolio_Project.covidvaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent !=''
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopVsVac;

-- Temp table
DROP TABLE IF EXISTS Portfolio_Project.Temp1;

CREATE TEMPORARY TABLE Portfolio_Project.Temp1
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO Portfolio_Project.Temp1
SELECT dea.continent,dea.location ,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.coviddeaths as dea
JOIN Portfolio_Project.covidvaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE vac.new_vaccinations !='' ;
-- WHERE dea.continent !='';

SELECT *,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project.Temp1;

-- Creating view to store data for later
CREATE VIEW Portfolio_Project.percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.coviddeaths as dea
JOIN Portfolio_Project.covidvaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT * FROM Portfolio_Project.percentpopulationvaccinated


