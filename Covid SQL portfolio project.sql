select * 
from PortfolioProject..CovidDeaths$
order by 3,4

Select *
from PortfolioProject..CovidVaccinations$
order by 3,4

--select the data the we are going to be needing

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths (Showing the likelihood of death/ country)

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathParcentage
from PortfolioProject..CovidDeaths$
where location like 'States'
order by 1,2

-- looking at total cases vs population (shows the percentage of population with covid)

select location, date, Population, total_cases, (total_cases/population)*100 as CasePerPopulation
from PortfolioProject..CovidDeaths$
--where location like '%europe%'
order by 1,2

-- Looking at countries with highest infection rate

select location, Population, MAX(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as HighestInfectionRate
from PortfolioProject..CovidDeaths$
--where location like '%europe%'
group by location, population
order by HighestInfectionRate desc

-- Showing countries with highest death per population

select location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount, max(total_deaths/population)*100 as HighestDeathRate
from PortfolioProject..CovidDeaths$
--where location like '%europe%'
group by location, population
order by HighestDeathRate desc

-- Showing countries with Highest Death Count

select location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by HighestDeathCount desc

-- Lets Break Things Down By Continents
-- Showing Continent with Highest Death Count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is null
order by 1,2

-- Covid Vaccination and deaths

SELECT *
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
order by dea.location

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.date) as VaccinationSum
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by dea.location, 3

-- CREATING A CTE
with popvsVac (continent, location, date, population, New_vaccinations, vaccinationSum)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.date) as VaccinationSum
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--
)

 select *, (vaccinationSum/population)*100 as PercentOfpeopleVaccinated
 from popvsVac
 order by 2, 3

 -- TEMP TABLE

 Drop table if exists #percentagePopulationVaccinated
 Create table #PercentagePopulationVaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 Population numeric,
 New_Vaccination numeric,
 RollingpeopleVaccinated numeric
 )
 insert into #PercentagePopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.date) as VaccinationSum
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

 select *, (RollingpeopleVaccinated/population)*100 as PercentOfpeopleVaccinated
 from #PercentagePopulationVaccinated
 order by 2, 3

 -- Creating view to store data for later visualisation

 create view PercentagePopulationVaccinated as 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.date) as VaccinationSum
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by dea.location, 3