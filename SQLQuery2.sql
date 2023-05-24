Select *
From PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--select data that we are going to use
Select location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths$
order by 3,4

--looking at total case VS Total Deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%india%'
order by 3,4

--Looking at TotalCase Vs Population
Select location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%india%'
order by 1,2


--Looking at Countries with Highest Infection Rate to Polulation
Select Location, Population, MAX(total_cases) AS HighestInfectionCount ,max((total_cases/population)*100) as 
PecentagePopulationInfected
From PortfolioProject..CovidDeaths$
--where location like '%india%'
Group by population, location
order by 4 desc


--Showing Countries with Highest Death Count

Select Location,MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
Group by location
order by 2 desc 


--Breaking it Down By Continent
Select continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
Group by continent
order by 2 desc 



--Showing Continent with Highest Death Count
Select location,MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is null
Group by location
order by 2 desc

/*select Continent, count(continent is null) as NullCount,
count(continent is not null) as NotNullCount
From PortfolioProject..CovidDeaths$
group by continent
--where location = continent*/

select location,continent,count(location)
From PortfolioProject..CovidDeaths$
group by location,continent
--where location = continent

--Global Numbers 
Select date,sum(total_cases) AS TotalCasesCount,
sum(cast(total_deaths as int)) as TotalDeathCount,
sum(cast(total_deaths as int))/sum(total_cases)*100
as DeathPercentage,
sum(new_cases) as TotalNewCases,
sum(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
group by date
order by 1 

Select sum(total_cases) AS TotalCasesCount,
sum(cast(total_deaths as int)) as TotalDeathCount,
sum(cast(total_deaths as int))/sum(total_cases)*100
as DeathPercentage,
sum(new_cases) as TotalNewCases,
sum(cast(new_deaths as int)) as TotalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
order by 1




--Looking at Total Polpulations Vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population
,vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as
RollingPopulationVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.date=vac.date 
	and dea.location=vac.location
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3


--Using CTE
--With PopVsVac (continent,location,date,population,new_vaccinations,RollingPopulationVaccinated)
--as
--(
--select dea.continent,dea.location,dea.date,dea.population
--,vac.new_vaccinations,
--Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as
--RollingPopulationVaccinated
--From PortfolioProject..CovidDeaths$ dea
--Join PortfolioProject..CovidVaccinations$ vac
--	on dea.date=vac.date 
--	and dea.location=vac.location
--where dea.continent is not null and vac.new_vaccinations is not null
--)
--Select *, RollingPopulationVaccinated/population*100
--From PopVsVac
--ORDER BY 2,3



--Using TempTable

/*
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_Vac numeric,
RollingPopulation numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population
,vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as
RollingPopulationVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.date=vac.date 
	and dea.location=vac.location
where dea.continent is not null and vac.new_vaccinations is not null

select *
From #PercentPopulationVaccinated
*/

--Bing correction ( for server 2014)
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_Vac numeric,
    RollingPopulation numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL;

SELECT *, RollingPopulation/population as RollingPopVsPopulation,
new_Vac/Nullif(RollingPopulation,0)
FROM #PercentPopulationVaccinated;
GO

--Creating View for viewing later

Create View PrecentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL



--drop view PrecentPopulationVaccinated