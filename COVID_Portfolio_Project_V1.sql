Select * from Covid_Deaths
where continent is not null
order by 3,4

--Select * from Covid_Vaccinations
--order by 3,4

--Select Data that we are going to use

select location, date,total_cases,new_cases,total_deaths,population
from Covid_Deaths
order by 1,2

--looking at total cases vs total deaths
-- shows the liklihood of dying of covid in your country
select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Covid_Deaths
Where location = 'United Kingdom'
order by 1,2

--select distinct Location
--from Covid_Deaths
--order by 1

--total cases vs populaiton
-- Shows what % got covid
select location, date,total_cases,population,(total_cases/population)*100 as PercentageGotCovid
from Covid_Deaths
Where location = 'United Kingdom'
order by 1,2

--looking at contries with the highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentageOfPopulationInfected
from Covid_Deaths
--Where location = 'United Kingdom'
where continent is not null
Group by location, population
order by PercentageOfPopulationInfected desc


--showing the highest death count per population
-- using cast because total_deaths is saved as a NVARCHAR

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid_Deaths
--Where location = 'United Kingdom'
where continent is not null
Group by location
order by TotalDeathCount desc

--lets break it down by continent
-- correct way - could add alias to location to pretent its continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid_Deaths
--Where location = 'United Kingdom'
where continent is null
and location not like ('%income%')
Group by location
order by TotalDeathCount desc

--other kind of correct way for use in tab later
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid_Deaths
--Where location = 'United Kingdom'
where continent is not null
--and location not like ('%income%')
Group by continent
order by TotalDeathCount desc

--Global numbers

select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
from Covid_Deaths
--Where location = 'United Kingdom'
where continent is not null
Group by date -- comment this out for total overall % and dont forget to remove date from select
order by 1,2

--Joins

--Looking at total population vs Vaccinaiton -- USE CTE
With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
--drop table is there so you can make alterations
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Making a View for later vis work

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated