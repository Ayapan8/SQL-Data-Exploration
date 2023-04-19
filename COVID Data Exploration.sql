select * from CovidDeaths$
where continent is not null
order by 3,4

select * from CovidVaccinations$

--Select  Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$ 
where continent is not null
order by 1,2



--Looking at Total cases vs Total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as InfectedPercentage
from CovidDeaths$
where location like'%India%'
and continent is not null
order by 1,2


--Looking at Total cases vs Population
--Shows what percentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
from CovidDeaths$
where location like'%India%'
order by 1,2


--Looking at Countries with HighestInfection Rate compared to population

select location,population,MAX(total_cases) as  HighestInfection,MAX((total_cases/population))*100 as InfectedPercentage
from CovidDeaths$
--where location like'%India%'
where continent is not null
GROUP BY location,population
order by InfectedPercentage 


--Showing Countries with Highest Death Count per Population


select location,MAX(cast(total_deaths as int)) as  TotalDeathCount
from CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


----Showing continents with the highest death count per population

select continent,MAX(cast(total_deaths as int)) as  TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select date,sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
--where location like'%India%'
where continent is not null
group by date
order by 1,2



--Looking at Total populations vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

from [dbo].[CovidDeaths$] as dea
join CovidVaccinations$ as vac

on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using CTE method

with PopvsVac(Continent,Location,Date,population,new_vaccinations,RollingPeopleVaccinated)
As
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

from [dbo].[CovidDeaths$] as dea
join CovidVaccinations$ as vac

on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac



--Using Temp Table

drop table if exists  #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar(250),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into  #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

from [dbo].[CovidDeaths$] as dea
join CovidVaccinations$ as vac

on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3


select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

from [dbo].[CovidDeaths$] as dea
join CovidVaccinations$ as vac

on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated

