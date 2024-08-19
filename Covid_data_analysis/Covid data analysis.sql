select * from PortfolioProject..CovidDeaths1 order by 3,4

select * from PortfolioProject..CovidVaccinations order by 3,4

select location,date,total_cases,new_deaths, total_deaths from PortfolioProject..CovidDeaths1 order by 1,2

--total cases vs total deaths

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths1 where location like '%state%' order by 1,2

--total cases vs population (% of population affected by covid)

select location,date,total_cases, population, (total_deaths/population)*100 as PopulationPercentageInfected 
from PortfolioProject..CovidDeaths1 where location like '%state%' order by 1,2

--infection rate vs population 

select location,population,max(total_cases) as HighestInfectionCount, max((total_deaths/population))*100 as PopulationPercentageInfected 
from PortfolioProject..CovidDeaths1 group by location, population order by 1,2

--death rate vs population 

select location,max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths1 where continent is not null group by location order by 2 desc

--death count by continent

select continent, max(total_deaths) as TotalDeathCount from PortfolioProject..CovidDeaths1
where continent is not null group by continent order by 2 desc;

select location, max(total_deaths) as TotalDeathCount from PortfolioProject..CovidDeaths1
where continent is null and location not like '%countries%' group by location order by 2 desc;


--global numbers

select date, sum(new_cases)--, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths1 where continent is not null group by date order by 1

 select date, sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths1 where continent is not null group by date order by 1



 select a.continent,a.location,a.date,a.population,b.new_vaccinations,
 sum(convert(bigint,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as RollingPeopleVaccinated  from 
 PortfolioProject..CovidDeaths1 a
 join PortfolioProject..CovidVaccinations b
 on a.location=b.location and a.date=b.date
 where a.continent is not null 
 order by 2,3

 --using cte

 with popvsvac (continent, location, date, population,new_vaccinations,  RollingPeopleVaccinated)
 as 
 (select a.continent,a.location,a.date,a.population,b.new_vaccinations,
 sum(convert(bigint,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as RollingPeopleVaccinated  from 
 PortfolioProject..CovidDeaths1 a
 join PortfolioProject..CovidVaccinations b
 on a.location=b.location and a.date=b.date
 where a.continent is not null )
 select *, (RollingPeopleVaccinated/population)*100 from popvsvac where location like '%states%'


 --temp table

 drop table #perpopvac
 create table #perpopvac(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric)
 insert into #perpopvac
 select a.continent,a.location,a.date,a.population,b.new_vaccinations,
 sum(convert(bigint,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as RollingPeopleVaccinated  from 
 PortfolioProject..CovidDeaths1 a
 join PortfolioProject..CovidVaccinations b
 on a.location=b.location and a.date=b.date
 where a.continent is not null 


 select *, (RollingPeopleVaccinated/population)*100 from #perpopvac




 --creating view

 Create view perpopvac as 
 select a.continent,a.location,a.date,a.population,b.new_vaccinations,
 sum(convert(bigint,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as RollingPeopleVaccinated  from 
 PortfolioProject..CovidDeaths1 a
 join PortfolioProject..CovidVaccinations b
 on a.location=b.location and a.date=b.date
 where a.continent is not null 

 select * from perpopvac