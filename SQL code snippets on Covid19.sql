/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [PortfolioProject].[dbo].[CovidDeaths]

/** Checking source data **/
  select * from CovidDeaths
  select * from CovidVaccinations
  select * from deaths

   select location,date,total_cases,new_cases,total_deaths,population
   from deaths 
   order by 1,2 

/**Data Analysis**/

/** Population by Continent**/
   select continent, max(population) as TotalPopulation 
   from CovidDeaths 
   group by continent
   order by TotalPopulation desc
                    
						/**Generated Columns**/

/** Total Cases Vs Total Deaths **/
   select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
   from CovidDeaths 
   order by 1,2

/** Total Covid Cases Vs Population **/
   select location,date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
   from deaths 
   --where location = 'North America'
   order by 1,2

/** Highest infection rate - country wise**/
  select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectedPercentage
   from deaths 
   group by location,population
   order by InfectedPercentage desc

/** Highest death count - country wise**/
   select location,MAX(cast(total_deaths as INT)) as HighesDeathCount
   from CovidDeaths 
   group by location
   order by HighesDeathCount desc

/** Highest death count - continent wise**/
   select continent,MAX(convert(int,total_deaths)) as HighesDeathCount
   from CovidDeaths 
   where continent is not null
   group by continent
   order by HighesDeathCount desc
	
/**Everyday New cases and New Deaths - globally**/

select date,SUM(cast(new_cases as int)) as TotalNewCases,SUM(cast(new_deaths as int)) as TotalNewDeaths 
--(SUM(cast(new_deaths as int))/SUM(cast(new_cases as int)))*100 as NewDeathPercentage
from CovidDeaths
group by date
order by 1,2
  
select SUM(cast(new_cases as int)) as TotalNewCases,SUM(cast(new_deaths as int)) as TotalNewDeaths 
from CovidDeaths
order by 1,2  

						/**JOIN - Using Vaccination Table**/

--select * from CovidVaccinations

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
order by 2,3

						 /**Using CTE**/

/**Using the RollingTotalVaccination as to calculate % of people vaccinated**/
 WITH PopVsVac 
 as 
 (
 select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
 )
 select *, (RollingTotalVaccination/population)*100
 from PopVsVac


						/**Creating TEMP TABLE**/

DROP TABLE IF EXISTS #PercentageofPeopleVaccinated
create table #PercentageofPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingTotalVaccination numeric
)
INSERT INTO #PercentageofPeopleVaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--order by 2,3

select *, (RollingTotalVaccination/population)*100 PercentageVaccinated
 from #PercentageofPeopleVaccinated

						/** Creating Views to store data**/

create view RollingTotalNumOfPeopleVaccinated as
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

select * from RollingTotalNumOfPeopleVaccinated


/** END **/

