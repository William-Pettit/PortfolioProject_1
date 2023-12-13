select *
From PortfolioProject_1..CovidVaccinations
order by date asc;

-- Altering data type for accurate results

alter table PortfolioProject_1..CovidVaccinations alter column date date;
alter table PortfolioProject_1..CovidDeaths alter column date date;
alter table PortfolioProject_1..CovidDeaths alter column total_deaths float;
alter table PortfolioProject_1..CovidDeaths alter column total_cases float;
alter table PortfolioProject_1..CovidDeaths alter column population float;


select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_1..CovidDeaths
order by 1,2;

--Total Cases vs Total Deaths


select location, date, total_cases, total_deaths, (total_deaths/(NULLIF(total_cases,0)))*100 as DeathPercentage
From PortfolioProject_1..CovidDeaths
where location = 'United States'
order by 1,2;

--Total Cases vs Population
--what percentage of poeple have gotten covid

select location, date, total_cases, population, (total_cases/(NULLIF(population,0)))*100 as InfectionPercentage
From PortfolioProject_1..CovidDeaths
--where location = 'United States'
order by 1,2;

-- Infected vs Population

select location, population, Max(total_cases) as MaxTotalCases, Max((total_cases/(NULLIF(population,0))))*100 as InfectionPercentage
From PortfolioProject_1..CovidDeaths
--where location = 'United States'
group by location, population
order by InfectionPercentage desc;

--Total Death Count by Location

select location, Max(total_deaths) as TotalDeathCount 
From PortfolioProject_1..CovidDeaths
--where location = 'United States'
where continent != ''
group by location
order by TotalDeathCount desc;


-- Total Death Count by Continent

select continent, Max(total_deaths) as TotalDeathCount 
From PortfolioProject_1..CovidDeaths
--where location = 'United States'
where continent  != ''
group by continent
order by TotalDeathCount desc;


-- global numbers

select date, sum(cast (new_cases as int)) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as float))/Nullif(sum(cast(new_cases as float)),0))*100 as DeathPercentage
From PortfolioProject_1..CovidDeaths
--where location = 'United States'
where continent != ''
group by date 
order by 1,2;

-- looking at total popuation vsvaccinations


Select*
from PortfolioProject_1..CovidDeaths as dea
join PortfolioProject_1..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date;



--Using CTE 


with PopvsVac (Continent, location, date, population,new_vaccinations, TotalVaccinationsPerLocation)
as
(
Select dea.continent,dea.location, dea.date, dea.population, nullif(vac.new_vaccinations,0) as new_vaccinations, 
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinationsPerLocation
	--(TotalVaccinationsPerLocation/population)*100

from PortfolioProject_1..CovidDeaths as dea
join PortfolioProject_1..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3;
)
select *, (TotalVaccinationsPerLocation/population)*100
from PopvsVac


--Using Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinationsPerLocation numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, nullif(vac.new_vaccinations,0) as new_vaccinations, 
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinationsPerLocation
	--(TotalVaccinationsPerLocation/population)*100
from PortfolioProject_1..CovidDeaths as dea
join PortfolioProject_1..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3

select *, (TotalVaccinationsPerLocation/population)*100
from #PercentPopulationVaccinated

--CREATING VIEW

use [PortfolioProject_1];

CREATE view PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, nullif(vac.new_vaccinations,0) as new_vaccinations, 
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinationsPerLocation
	--(TotalVaccinationsPerLocation/population)*100
from PortfolioProject_1..CovidDeaths as dea
join PortfolioProject_1..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3

SELECT * FROM information_schema.views;
