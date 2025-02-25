
--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


--DATA EXPLORATION

 --Total data
Select COUNT(iso_code) as Total_data
From [dbo].[CovidDeaths$]

--Checking for nulls

Select COUNT(*)-COUNT(continent) as continent,
COUNT(*)-COUNT(iso_code) as country_abrv,
COUNT(*)-COUNT(location) as location,
COUNT(*)-COUNT(date) as date,
COUNT(*)-COUNT(total_cases) as total_cases,
COUNT(*)-COUNT(new_cases) as new_cases,
COUNT(*)-COUNT(total_deaths) as total_deaths,
COUNT(*)-COUNT(new_deaths) as new_deaths,
COUNT(*)-COUNT(population) as population
From [dbo].[CovidDeaths$]



--DATA ANALYSIS

-- Global death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
order by 1,2


-- Total death count per continent

Select continent, SUM(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Highest percentage of infection rate per country

Select top 8 Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- Monthly infection rate per country

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths$
Order by 1,2


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




