select *
from [Covid Deaths]
where continent is not null
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from [Covid Deaths]
order by 1,2

-- total case vs total deaths, percentage of those who died had it
--- shows likelihood of dying 
Select location, date, total_cases, total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
from [Covid Deaths]
where location like 'canada'
order by 1, 2

-- look at total case versus population 
-- shows what percentage of population got covid

Select location, date, total_cases, population, (cast(total_cases as decimal))/(cast(population as decimal))*100 as PercentageofPopulationWithCovid
from [Covid Deaths]
where location like 'canada'
order by 1, 2

-- what countries have highest infection rate compuared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as decimal))/(cast(population as decimal))*100 as PercentageofPopulationWithCovid
from [Covid Deaths]
group by location, population
order by 4 desc

-- show the countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid Deaths]
where continent is not null
group by location
order by 2 desc

--- now the US is the higher death count... ??? 
--- what is the highest percentage 

--- lets break everything down by continent 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid Deaths]
where continent is not null
group by location
order by 1 

--- the rows where continent is null is where location is actually the continent

--- now showing continent with highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid Deaths]
where continent is null
group by location
order by 1

---global numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/NULLIF(sum(new_cases)*100,0) as DeathPercentage
from [Covid Deaths]
where continent is not null
group by date
order by 1, 2



select *
from [Covid Deaths] as dea
join [Covid Vaccinations] as vac
on dea.location = vac.location
and dea.date = vac.date

--- looking at total population vs new vaccination per day


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as rollingpeoplevaccinated 
from [Covid Deaths] as dea
join [Covid Vaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- use cte 

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as rollingpeoplevaccinated
from [Covid Deaths] as dea
join [Covid Vaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100 as percentageofpeoplevaccinated
from popvsvac




-- temp table

drop table if exists #percecntpopulationvaccinated -- just add this if you plan on making alterations 
create table #percecntpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
rollingpeoplevaccinated numeric
)

insert into #percecntpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as rollingpeoplevaccinated 
from [Covid Deaths] as dea
join [Covid Vaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *,(rollingpeoplevaccinated/population)*100 as percentageofpeoplevaccinated
from #percecntpopulationvaccinated



-- creating view to store data for later visualization

create view percecntpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as rollingpeoplevaccinated 
from [Covid Deaths] as dea
join [Covid Vaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3