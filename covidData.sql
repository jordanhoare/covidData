-----------------------------------------------------------------------------
------------------------------ G L O B A L ---------------------------------- 
-----------------------------------------------------------------------------

--------------  Death percentage (of world reported cases)
-----------------------------------------------------------------------------
Create View GlobalDeathPercentage as
SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..covidDeaths
Where continent is not null


--------------  Vaccinations Global
-----------------------------------------------------------------------------
Create View GlobalVaccinations as
SELECT 
	MAX(dea.population) as WorldPopulation,
	MAX(cast(vac.people_fully_vaccinated as int)) as FullyVaccinatedGlobal, 
	MAX(cast(vac.people_vaccinated as int)) as VaccinatedGlobal, 
	MAX(cast(vac.people_vaccinated as int))/MAX(dea.population)*100 as PercentVaccinatedGlobal,
	MAX(cast(vac.people_fully_vaccinated as int))/MAX(dea.population)*100 as PercentFullyVaccinatedGlobal
FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location like 'World'







-----------------------------------------------------------------------------
--------------------------- C O N T I N E N T ------------------------------- 
-----------------------------------------------------------------------------

--------------  Vaccinations per continent
-----------------------------------------------------------------------------
Create View ContinentVaccinations as
SELECT dea.Continent as Continent, 
	MAX(cast(vac.people_vaccinated as int)) as VaccinatedContinent, 
	MAX(cast(vac.people_fully_vaccinated as int)) as FullyVaccinatedContinent, 
	MAX(cast(vac.people_fully_vaccinated as int))/MAX(dea.population)*100 as PercentFullyVaccinatedContinent,
	MAX(cast(vac.people_vaccinated as int))/MAX(dea.population)*100 as PercentVaccinatedContinent
FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Group by dea.Continent



--------------  Death percentage (of reported cases) per continent 
-----------------------------------------------------------------------------
Create View ContinentDeathPercentage as
SELECT dea.Continent as Continent, SUM(cast(new_deaths as int)) as totalDeaths, MAX(cast(total_deaths as int))/MAX(total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Group by dea.Continent 








-----------------------------------------------------------------------------
---------------------------- C O U N T R Y ---------------------------------- 
-----------------------------------------------------------------------------

---------------  DeathPercentage vs Total Cases by Country
-----------------------------------------------------------------------------
Create View CountryDeathPercentage as
SELECT location, SUM(ISNULL(new_cases, 0)) as totalCases, SUM(ISNULL(cast(new_deaths as int), 0)) as totalDeaths, ISNULL(SUM(cast(new_deaths as int))/SUM(new_cases)*100,0) as DeathPercentage
From [Portfolio Project]..covidDeaths
Where continent is not null
Group by location


--------------  InfectionRate (% of population who have contracted virus)
-----------------------------------------------------------------------------
Create View CountryInfectionRate as
SELECT Location, Population, MAX(total_cases) as TotalCases, ISNULL(MAX((total_cases/Population))*100,0) as InfectionRate
from [Portfolio Project]..covidDeaths
Where continent is not null
Group by location, population






-----------------------------------------------------------------------------
------------------------ T I M E   S E R I E S ------------------------------ 
-----------------------------------------------------------------------------

--------------  Death / Cases Percentage
-----------------------------------------------------------------------------
Create View DailyCasesDeathsPercentage as
WITH DeathOverTime (Location, Date, Population, new_deaths, new_cases, DeathsToDate, CasesToDate)
as
(
SELECT dea.location, dea.date, dea.population, dea.new_deaths, dea.new_cases,
	SUM(CONVERT(int,dea.new_deaths)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as DeathsToDate, 
	SUM(dea.new_cases) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as CasesToDate
FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
SELECT *, (DeathsToDate/CasesToDate)*100 as DeathPercentageOfCases
FROM DeathOverTime


--------------  People_fully_vaccinated
-----------------------------------------------------------------------------
Create View DailyFullyVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, ISNULL(vac.new_vaccinations, 0) as NewVaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.date) as VaccinationsToDate
	, (vac.people_fully_vaccinated/population)*100 as PercentFullyVaccinated
FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null





