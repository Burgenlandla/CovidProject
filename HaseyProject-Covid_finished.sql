select *
from cov_deaths
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from cov_deaths
order by 1,2

--- Total cases vs. total deaths ---


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from cov_deaths
Where location = 'Austria'
order by 1,2


--- New cases vs. new deaths ---


select location, date, new_cases, new_deaths, (new_cases/new_deaths)*100 as DeathPercentage
from cov_deaths
Where location = 'Austria'
order by 1,2


--- cases vs- population

select location, date, population, new_cases, (new_cases/population)*100 as CasesperPop
from cov_deaths
Where location = 'Austria'
order by 1,2

-- countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as Percntpopulationinfected
from cov_deaths
-- Where location = 'Austria'
Group by location, population
order by Percntpopulationinfected desc




-- countries with highest death count per population

select location, max(total_deaths) as TotalDeathCount
from cov_deaths
-- Where location = 'Austria'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(total_deaths) as TotalDeathCount
from cov_deaths
-- Where location = 'Austria'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- showing contintents with the highest death count per pop

select continent, max(total_deaths) as TotalDeathCount
from cov_deaths
-- Where location = 'Austria'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

select  date, sum(new_cases) as sumnewcases, sum(new_deaths) as sumnewdeaths, sum(new_deaths)/sum(new_cases)*100 as deathspernew -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from cov_deaths
where continent is not null
-- Where location = 'Austria'
Group by date
order by 1,2

-- total newdeaths/newcases

select sum(new_cases) as sumnewcases, sum(new_deaths) as sumnewdeaths, sum(new_deaths)/sum(new_cases)*100 as deathspernew -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from cov_deaths
where continent is not null
-- Where location = 'Austria'
order by 1,2

-- looking at population vs vax

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
from [Haseys 1. Project]..cov_deaths dea
Join [Haseys 1. Project]..cov_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 1,2,3

ALTER TABLE vax  ALTER COLUMN new_vaccinations  nvarchar(150)
ALTER Table cov_vax ALTER column new_vaccinations nvarchar(150)
ALTER Table cov_deaths ALTER column location nvarchar(150)

With popvsvac (Cotinent, Location, Date, Population, New_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
from [Haseys 1. Project]..cov_deaths dea
Join [Haseys 1. Project]..cov_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where  dea.continent is not null and dea.continent= 'Europe'
order by 2,3
)

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
from [Haseys 1. Project]..cov_deaths dea
Join [Haseys 1. Project]..cov_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent = 'europe' and dea.continent is not null
order by 1,2


 -- USE CTE
With popvsvac (Cotinent, Location, Date, Population, New_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
from [Haseys 1. Project]..cov_deaths dea
Join [Haseys 1. Project]..cov_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where  dea.continent is not null and dea.continent= 'Europe'
-- order by 2,3
)
Select *, (rollingpeoplevaccinated/Population)*100 as vacpop
From popvsvac

--- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
from [Haseys 1. Project]..cov_deaths dea
Join [Haseys 1. Project]..cov_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where  dea.continent is not null and dea.continent= 'Europe'

Select *, (rollingpeoplevaccinated/Population)*100 as vacpop
From #PercentPopulationVaccinated

-- Creating view to store  data for later visualizations

Create View PercentPopulatioVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
from [Haseys 1. Project]..cov_deaths dea
Join [Haseys 1. Project]..cov_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where  dea.continent is not null 

