SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT 
DISTINCT location,
continent
FROM PortfolioProject..CovidVaccination
ORDER BY continent 

-- Select Data List that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total Deaths
-- shows the likelihood of dying if you contract COVID in your country

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths,
   (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage 
FROM 
    PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2;

--Looking at the total-cases vs population

 SELECT 
    location, 
    date, 
    total_cases, 
    population,
    (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 
    1, 2;

-- Looking at countries with the highest infection rate compared to population

SELECT 
    location, 
   population,
   MAX(total_cases) as HighestInfectionCount,
   MAX(CAST(total_cases AS FLOAT)/population)*100 as PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by location, Population
ORDER BY PercentPopulationInfected DESC;

-- Showing the countries with highest Death Count per population and its percentage

SELECT 
    location, 
   population,
   MAX(CAST(total_deaths AS FLOAT)) as HighestDeathCount,
   MAX(CAST(total_deaths AS FLOAT)/population)*100 as PercentPopulationDeath
FROM 
    PortfolioProject..CovidDeaths
	Where continent IS NOT NULL
Group by location, Population
ORDER BY PercentPopulationDeath DESC;

-- CONTINENTS

-- Showing death count by continent

SELECT 
continent,
   SUM(new_deaths) AS HighestDeathCount
FROM 
    PortfolioProject..CovidDeaths
	Where continent IS not null
Group by continent
ORDER BY HighestDeathCount DESC;

-- Total cases over population on each continent
 SELECT DISTINCT
  continent,
  MAX(population) AS Population,
   SUM(CAST (new_cases AS FLOAT)) AS TotalCases,
    (SUM(CAST(new_cases AS FLOAT)) / MAX(population)) * 100 AS PercentPopulationInfectedContinent
FROM 
    PortfolioProject..CovidDeaths
	Where continent IS NOT NULL
	GROUP BY continent
ORDER BY  PercentPopulationInfectedContinent


-- GLOBAL NUMBERS

--number of total cases 

SELECT 
   SUM(new_cases) AS TotalNumberofCases
FROM 
    PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL

-- number of deaths

SELECT 
   SUM(new_deaths) AS TotalNumberofDeaths
FROM 
    PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL

	-- Number of deaths and cases reported on each days

SELECT 
	date,
	SUM(new_cases)  AS cases,
	SUM(new_deaths) AS Deaths,
	SUM(new_deaths)/SUM(new_cases) *100 AS DeathPercentage

FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY date
 ORDER BY 1,2

 -- number of deaths and cases of COVID in the world

SELECT 
	SUM(new_cases)  AS cases,
	SUM(new_deaths) AS Deaths,
	SUM(new_deaths)/SUM(new_cases) *100 AS DeathPercentage

FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL
 ORDER BY 1,2

 -- Looking at Total Population vs Vaccination

 SELECT 
 dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition by dea.location) AS CountryVaccination
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
 ON dea.location = vac.location
 AND dea.date = vac.date 
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3

 SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS CountryVaccination
FROM 
    PortfolioProject..CovidDeaths dea
JOIN (
    SELECT 
        location, 
        date, 
        SUM(CAST (new_vaccinations AS FLOAT)) AS new_vaccinations
    FROM 
        PortfolioProject..CovidVaccination
    GROUP BY 
        location, 
        date
) vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, 
    dea.date;


 -- Looking at Vaccinations in the countries per continent

  SELECT 
 dea.continent,
 SUM(population) AS TotalPopulation,
   SUM(CAST(new_vaccinations AS FLOAT)) AS Totalvaccination
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
 ON dea.location = vac.location
 AND dea.date = vac.date 
 WHERE dea.continent IS NOT NULL
 GROUP BY dea.continent
 ORDER BY 3 DESC


 
 -- Using CTE to find the total population vs vaccination

 WITH CTE_PeopleVaccinated (continent, location, date, population, new_vaccination, CountryVaccination) AS (
    SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition by dea.location ORDER BY dea.date) AS CountryVaccination
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        (SELECT 
             date, 
             location, 
             SUM(CAST(new_vaccinations AS FLOAT)) AS new_vaccinations
         FROM 
             PortfolioProject..CovidVaccination 
         GROUP BY 
             date, location) vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date 
    WHERE 
        dea.continent IS NOT NULL
)
SELECT * FROM CTE_PeopleVaccinated;


-- Creating View for Visualization in Tableau

CREATE VIEW PopulationVaccinate
AS 
SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition by dea.location ORDER BY dea.date) AS CountryVaccination
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        (SELECT 
          date, location, SUM(CAST(new_vaccinations AS FLOAT)) AS new_vaccinations
         FROM 
             PortfolioProject..CovidVaccination 
         GROUP BY 
             date, location) vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date 
    WHERE 
        dea.continent IS NOT NULL

		SELECT *
		FROM PopulationVaccinated