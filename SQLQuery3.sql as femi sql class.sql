select * from portfolioproject.dbo.[DEATH VR]
order by 3,4
select location, date, total_cases, new_cases, total_deaths,  population
from portfolioproject.dbo.[DEATH VR] order by 1,2


select location, date,new_cases, total_cases,  total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject.dbo.[DEATH VR] order by 1,2

select location, date, population, total_cases,  (total_cases/population)*100 as percentagepopulationinfected
from portfolioproject.dbo.[DEATH VR]
where location like '%state%'
order by 1,2



select location,  population, max(total_cases) as highinfectioncout, max((total_cases/population))*100 as percentagepopulationinfected
from portfolioproject.dbo.[DEATH VR]
where location like '%state%'
group by location,  population
order by percentagepopulationinfected desc



select location,   max(total_deaths) as totaldeathcount 
from portfolioproject.dbo.[DEATH VR]
where location like '%state%'
where continent is not null
group by location
order by totaldeathcount desc



select continent,   max(total_deaths) as totaldeathcount 
from portfolioproject.dbo.[DEATH VR]
where location like '%state%'
where continent is  not null
group by continent
order by totaldeathcount desc


 Gobal Numbers 
select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/NULLIF (sum(new_cases),0)*100 as deathpercentage
from portfolioproject.dbo.[DEATH VR]
where continent is not  null
group by date
order by deathpercentage desc

looking at total population vs vaccination 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum((  vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date  ROWS UNBOUNDED PRECEDING )rowingpeoplevaccinated
from portfolioproject.dbo.[DEATH VR] dea
join portfolioproject.dbo.[VACCINATION VR] vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not  null
order by  2,3

with popvsvac (continent,location,date,population,new_vaccinations,rowingpeoplevaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum((  vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date  ROWS UNBOUNDED PRECEDING )rowingpeoplevaccinated
from portfolioproject.dbo.[DEATH VR] dea
join portfolioproject.dbo.[VACCINATION VR] vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not  null
)
select *, (rowingpeoplevaccinated/population)*100
from popvsvac


--temp table
drop table if exists #percentagepopulationvaccinated 
create table #percentagepopulationvaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentagepopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum((  vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date  ROWS UNBOUNDED PRECEDING )rollingpeoplevaccinated
from portfolioproject.dbo.[DEATH VR] dea
join portfolioproject.dbo.[VACCINATION VR] vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not  null
select *, (rollingpeoplevaccinated/population)*100

from #percentagepopulationvaccinated


creating view to store data for later visualizations

create view percentagepopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum((  vac.new_vaccinations ))over(partition by dea.location order by dea.location, dea.date  ROWS UNBOUNDED PRECEDING )rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from portfolioproject.dbo.[DEATH VR] dea
join portfolioproject.dbo.[VACCINATION VR] vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not  null
--order by 2,3
 
 select * from percentagepopulationvaccinated