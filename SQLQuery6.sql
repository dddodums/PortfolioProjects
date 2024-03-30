

Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3, 4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3, 4

--Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

--Looking at Total cases vs Total deaths
--Shows likelyhood of dying in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states'
and where continent is not null
order by 1, 2

--Looking at Total cases vs Population
--Shows the population that got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%states'
order by 1, 2


--Looking at countries with highest infection rate with respect to population

Select Location, Population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as 
PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states'
where continent is not null
Group by location, population
order by PercentagePopulationInfected desc

--Showing the countries with highest death count per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states'
where continent is not null
Group by location
order by TotalDeathCount desc

--Lets break things down by continent
--Showing the continents with the highest death  count per person
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states'
where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states'
where continent is null
Group by location
order by TotalDeathCount desc

--Global numbers

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states'
where continent is not null
order by 1, 2


Select date, sum(total_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths, (sum(cast(total_deaths as int))/sum(total_cases))*100 
as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states'
where continent is not null
group by date
order by 1, 2



--Looking at Total Polpulation vaccicated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (int, new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3



--Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (int, new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp table
Drop table if exists #PercentPopuationVaccinated
Create table #PercentPopuationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopuationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (int, new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopuationVaccinated


--Creating view to store data for later visualization
Create view PercentPopuationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (int, new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select * 
From PercentPopuationVaccinated



