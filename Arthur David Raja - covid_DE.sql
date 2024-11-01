SELECT * FROM portfolio..CovidDeaths$
where continent is not null
order by 3,4

--SELECT * FROM portfolio..CovidVaccinations$
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio..CovidDeaths$
order by 1,2


--TOTAL CASES VS TOTAL DEATH
--SHOWS LIKELYHOOD OF DYING IF YOU CONTRACT WITH COVID IN OUR COUNTRY 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)* 100 as  death_percentage
FROM portfolio..CovidDeaths$
WHERE location like '%states%'
order by 1,2 

--LOOKING AT TOTAL CASES VS POPULATION 
-- indicates percentage of poluation who got covid

SELECT location, date, total_cases, population, (total_cases/population)* 100 as death_percentage
FROM portfolio..CovidDeaths$
--WHERE location like '%states%'
order by 1,2 

--- highest infection rate country
SELECT location, population , MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))* 100 as percentpopulationinfected
FROM portfolio..CovidDeaths$
GROUP BY location, population
order by percentpopulationinfected DESC
 
 

 -- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION  
 SELECT location, MAX(cast(total_deaths as int))as total_deathcount
FROM portfolio..CovidDeaths$
where continent is not null
GROUP BY location
order by total_deathcount DESC

-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT 

SELECT continent, MAX(cast(total_deaths as int))as total_deathcount
FROM portfolio..CovidDeaths$
where continent is not null
GROUP BY continent
order by total_deathcount DESC

-- global numbers
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as new_deathpercentage--total_deaths, (total_deaths/total_cases)* 100 as  death_percentage
FROM portfolio..CovidDeaths$
--WHERE location like '%states%'
where continent is not null
--group by date
order by 1,2


SELECT * 
FROM portfolio..CovidVaccinations$



SELECT *
FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac 
ON 
	dea.date=vac.date and dea.location = vac.location

--CTE - CUMMALATIVE CALCULATION FOR VACCINATION

with popvsvac (continent, location, date, population, new_vaccinations , rollingpeople_vaccinated)
as
(
SELECT dea.continent ,dea.location,dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location, dea.date) as rollingpeople_vaccinated 
FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac 
ON 
	dea.date=vac.date and dea.location = vac.location
	WHERE dea.continent is not null
	--order by 2,3
)
SELECT *, (rollingpeople_vaccinated/population)*100
FROM popvsvac


-- temp table

DROP TABLE IF exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeople_vaccinated numeric 
)


INSERT into #PercentPopulationVaccinated
SELECT dea.continent ,dea.location,dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location, dea.date) as rollingpeople_vaccinated 
FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac 
ON 
	dea.date=vac.date and dea.location = vac.location
	WHERE dea.continent is not null
	--order by 2,3


SELECT *, (rollingpeople_vaccinated/population)*100
FROM #PercentPopulationVaccinated


CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent ,dea.location,dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location, dea.date) as rollingpeople_vaccinated 
FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac 
ON 
	dea.date=vac.date and dea.location = vac.location
	WHERE dea.continent is not null
	--order by 2,3

SELECT * FROM
Percent_Population_Vaccinated