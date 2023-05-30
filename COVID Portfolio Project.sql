select *
from PortfolioMain..CovidVaccine
order by 3, 4

select *
from PortfolioMain..CovidDeath
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioMain..CovidDeath
order by 1, 2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
	--SHOWS THE ODDS OF DYING DUE TO COVID CONTRACTION IN A COUNTRY

select location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercent
from PortfolioMain..CovidDeath
where location like '%nigeia%'
order by 1, 2

--LOOKING AT TOTAL CASES VS POPULATION

select location, date, total_cases, Population, (cast(total_cases as float)/cast(population as float)) as InfectedRate
from PortfolioMain..CovidDeath
where location like '%nigeria%'
order by 1, 2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION ATE COMPARED TO POPULATION

select location, Population, max(cast(total_cases as float)) as HighestInfectionCount, max((cast(total_cases as float)/cast(population as float)))*100 as InfectedRate
from PortfolioMain..CovidDeath
group by location, population
order by InfectedRate desc


--SHOWING CONTINENT WITH HIGHEST DEATH COUNT

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioMain..CovidDeath
WHERE continent is not null
group by continent
order by HighestDeathCount desc


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioMain..CovidDeath
where continent is not null
group by location
order by HighestDeathCount desc


--GLOBAL NUMBERS

select sum(cast(new_cases as int)) TotalNewCases, sum(cast(new_deaths as int)) TotalNewDeaths, sum(cast(new_deaths as int))/NULLIF(sum(cast(new_cases as float)), 0)*100 as DeathPercent
from PortfolioMain..CovidDeath
--where location like '%nigeia%'
where continent is not null
--group by date
order by 1, 2


--LOOKING AT TOTAL POPULATION VS DEATH

select dea.continent, dea.location, dea.date, dea.population, cast(dea.weekly_hosp_admissions as int) WeeklyHospAdmin, sum(cast(dea.weekly_hosp_admissions as int)) over (partition by dea.location order by dea.date) WeeklyHospAdminSum
from PortfolioMain..CovidDeath Dea
join PortfolioMain..CovidVaccine Vac
	on vac.location = dea.location
	and vac.date = dea.date
--(cast(new_cases as int)(cast(new_cases as int)
where dea.weekly_hosp_admissions is not null
order by 2, 3

--EMPLOYING CTE

with PopVsAdmin (Continent, Location, Date, Populaton, WeeklyHospAdmin, WeeklyHospAdminSum)
as 
(
select dea.continent, dea.location, dea.date, dea.population, cast(dea.weekly_hosp_admissions as int) WeeklyHospAdmin, sum(cast(dea.weekly_hosp_admissions as int)) over (partition by dea.location order by dea.date) WeeklyHospAdminSum
from PortfolioMain..CovidDeath Dea
join PortfolioMain..CovidVaccine Vac
	on vac.location = dea.location
	and vac.date = dea.date
--(cast(new_cases as int)(cast(new_cases as int)
where dea.weekly_hosp_admissions is not null
--order by 2, 3
)

select *, (WeeklyHospAdmin/Populaton)*100 as WeeklyAdminPercent
from PopVsAdmin


--USING TEMP TABLE

Drop table if exists #PercentWeeklyAdmission
create table #PercentWeeklyAdmission
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
WeeklyHospAdmin numeric,
WeeklyHospAdminSum numeric
)

insert into #PercentWeeklyAdmission
select dea.continent, dea.location, dea.date, dea.population, cast(dea.weekly_hosp_admissions as int) WeeklyHospAdmin, sum(cast(dea.weekly_hosp_admissions as int)) over (partition by dea.location order by dea.date) WeeklyHospAdminSum
from PortfolioMain..CovidDeath Dea
join PortfolioMain..CovidVaccine Vac
	on vac.location = dea.location
	and vac.date = dea.date
where dea.weekly_hosp_admissions is not null
--order by 2, 3

select *, (WeeklyHospAdmin/Population)*100 as WeeklyAdminPercent
from #PercentWeeklyAdmission

--CREATING VIEW FOR LATER VISUALZATION

use PortfolioMain
go
Create view WeeklyAdmin as
select dea.continent, dea.location, dea.date, dea.population, cast(dea.weekly_hosp_admissions as int) WeeklyHospAdmin, sum(cast(dea.weekly_hosp_admissions as int)) over (partition by dea.location order by dea.date) WeeklyHospAdminSum
from PortfolioMain..CovidDeath Dea
join PortfolioMain..CovidVaccine Vac
	on vac.location = dea.location
	and vac.date = dea.date
where dea.weekly_hosp_admissions is not null

