
--Test the data by selecting the contents of the table 'CovidDeaths'

Select *
From PortfolioProjects..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date,  new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract covid in my country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%somalia%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Showing what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
order by 1,2

-- Showing the percentage of people infected with Covid in Somalia
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Where location like '%somalia%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- countries with lowest infection rate per population
Select Location, Population, min(total_cases) as HighestInfectionCount,  min((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Countries with Lowest Death Count per Population
Select Location, min(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Showing contintents with the lowest death count per population
Select continent, min(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS






-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select codea.continent, codea.location, codea.date, codea.population, covac.new_vaccinations
, SUM(CONVERT(int,covac.new_vaccinations)) OVER (Partition by codea.Location Order by codea.location, codea.Date) as CumulativeVacination
From PortfolioProjects..CovidDeaths codea
Join PortfolioProjects..CovidVaccinations covac
	On codea.location = covac.location
	and codea.date = covac.date
where codea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVacination)
as
(
Select codea.continent, codea.location, codea.date,codea.population, covac.new_vaccinations
, SUM(CONVERT(int,covac.new_vaccinations)) OVER (Partition by codea.Location Order by codea.location, codea.Date) as CumulativeVacination
From PortfolioProjects..CovidDeaths codea
Join PortfolioProjects..CovidVaccinations covac
	On codea.location = covac.location
	and codea.date = covac.date
where codea.continent is not null 

)
Select *, (CumulativeVacination/Population)*100
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
CumulativeVacination numeric
)

Insert into #PercentPopulationVaccinated
Select codea.continent, codea.location, codea.date, codea.population, covac.new_vaccinations
, SUM(CONVERT(float,covac.new_vaccinations)) OVER (Partition by codea.Location Order by codea.location, codea.Date) as CumulativeVacination
From PortfolioProjects..CovidDeaths codea
Join PortfolioProjects..CovidVaccinations covac
	On codea.location = covac.location
	and codea.date = covac.date


Select *, (CumulativeVacination/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date