
Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select Data that I'm going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
 Select Location, date, total_cases,total_deaths, (TRY_CAST(total_deaths AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(total_cases AS NUMERIC(10, 2)), 0)) * 100.0 AS DeathPercentage
 From [Portfolio Project]..CovidDeaths
 Where Location like '%mexico%'
 and continent is not null
 order by 1,2

 

 -- Looking at the Total Cases vs Population
 Select Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
 From [Portfolio Project]..CovidDeaths
 --Where Location like '%mexico%'
 order by 1,2


 -- Looking at Countries with  Highest Infection Rate compared to Population
 Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
 From [Portfolio Project]..CovidDeaths
 --Where Location like '%mexico%'
 Group by location, population
 order by PercentPopulationInfected desc



 
 --Showing continent with the Highest death count per population
 Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..CovidDeaths
 --Where location like '%mexico'%
 Where continent is not null
 Group by continent
 order by TotalDeathCount desc




-- GLOBAL NUMBERS

Select SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS GlobalDeathPercentage 
 From [Portfolio Project]..CovidDeaths
 --Where Location like '%mexico%'
 where continent is not null
 --Group by date
 order by 1,2



 -- Looking at Total Population vs Vaccinations
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) 
From [Portfolio Project]..CovidDeaths dea 
Join [Portfolio Project]..CovidVaccinations vac 
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) 
From [Portfolio Project]..CovidDeaths dea 
Join [Portfolio Project]..CovidVaccinations vac 
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea 
Join [Portfolio Project]..CovidVaccinations vac 
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;





--Creating view to store data for later visualization
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea 
Join [Portfolio Project]..CovidVaccinations vac 
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3



Select *
From PercentPopulationVaccinated


















 --Showing Countries with Highest Death Count per Population
 Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..CovidDeaths
 --Where location like '%mexico'%
 Where continent is not null
 Group by location
 order by TotalDeathCount desc
