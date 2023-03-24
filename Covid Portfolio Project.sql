--Selecting the data

Select * from PortfolioProject..CovidDeaths$ where continent is null

--looking at the total cases vs total deaths
--Also rounding up the percentage and concatinating it with '%' as CovidDeathPercentage to get a good understanding of the data

Select	location,date,total_cases,total_deaths,
		concat(Round ((CONVERT(float,total_deaths ) / CONVERT(float, total_cases))*100,2),'%') as CovidDeathPercentage		
from PortfolioProject..CovidDeaths$ 
where location like 'India' 
order by 1,2

--Looking at the Total Cases vs Population

Select	 location,date,total_cases,population , 
		concat(round ((total_cases/population)*100,2),'%') as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$ 
where location like 'India' 
order by 1,2

--Looking at the Countries with Highest Infection rate compared to Population

Select	location,max(cast(total_cases as int)) as HighestInfectionCount,population , 
		max(concat(round ((total_cases/population)*100,2),'%')) as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by  population,location
order by  HighestInfectionCount desc

--Countries with Highest Death Count by Population and Death Percentage by Population

Select	location,max(cast(total_deaths as int)) as TotalDeathCount,population , 
		max(concat(round ((total_deaths/population)*100,2),'%')) as DeathPercentageByPopulation
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by  population,location
order by  TotalDeathCount desc


--Highest death count by population

Select continent,
	max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by  continent
order by  TotalDeathCount desc


--Global Number's

--This query throwing us "Warning: Null value is eliminated by an aggregate or other SET operation" 

Select  sum(new_cases)as total_cases, sum(new_deaths) as total_deaths,
		sum (new_deaths)/sum (new_cases)*100 as CovidDeathPercentage
from PortfolioProject..CovidDeaths$ 
where continent is not null
--group by date
order by 1,2


--Total Population vs Vaccinations (SQL query joins two tables, calculates a rolling sum of new vaccinations for each location, and calculates the percentage of people vaccinated in each location based on that rolling sum and the population data.)

with PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;
)
select *,concat( round((RollingPeopleVaccinated/population)*100,2),'%') as PercentageOfPeopleVaccinated  --The percentage is going over 100 %, there may be some inaccuracies in regards to the New_vaccinations 
from PopVsVac


--Now by Using Temp Table

--Drop table if exists #PercentPopulationVaccinated --to avoid errors if the table already exists from a previous execution of the script.
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated decimal(18,2)
)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;
SELECT *, CONCAT(CAST(ROUND(RollingPeopleVaccinated/population*100, 2) AS decimal(18,2)), '%') AS PercentageOfPeopleVaccinated
FROM #PercentPopulationVaccinated





--Creating View for later visualization

create view PercentageOfPeopleGlobal as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;


select * from  PercentageOfPeopleGlobal


create view IndiaCovidNumbers as
Select	 location,date,total_cases,population , 
		concat(round ((total_cases/population)*100,2),'%') as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$ 
where location like 'India' 
--order by 1,2


select * from IndiaCovidNumbers