use covid_analysis

---
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[population]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [covid_analysis].[dbo].[covid_deaths];



  --
  select location, date, total_cases, new_cases, total_deaths, population
  FROM [covid_analysis].[dbo].[covid_deaths]
  order by 1, 2;



--likelyhood of death if you contract covid
  select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
  FROM [covid_analysis].[dbo].[covid_deaths]
  where location like '%pakistan%'
  order by 1, 2;

  --total percentage of covid patients
  select location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
  FROM [covid_analysis].[dbo].[covid_deaths]
  where location like '%pakistan%'
  order by 1, 2;

  --countries with max infection rate 
  select location, max(total_cases) as higest_cases, population, max((total_cases/population))*100 as covid_percentage
  FROM [covid_analysis].[dbo].[covid_deaths]
  group by location, population
  order by covid_percentage desc;

  --countries with max death rate 
  select location, max(cast(total_deaths as int)) as higest_deaths
  FROM [covid_analysis].[dbo].[covid_deaths]
  where continent is not null 
  group by location
  order by higest_deaths desc;


  --
  select location, max(cast(total_deaths as int)) as higest_deaths
  FROM [covid_analysis].[dbo].[covid_deaths]
  where continent is not null 
  group by location
  order by higest_deaths desc;

--total new cases globally
select date, 
	sum(new_cases) as total_cases, 
	sum(cast(new_deaths as int)) as total_deaths,
	format((sum(cast(new_deaths as int))/sum(new_cases))*100, 'p3') as death_percentage
FROM [covid_analysis].[dbo].[covid_deaths]
where continent is not null 
group by date
order by 2 desc;


--
select *
FROM [covid_analysis].[dbo].[covid_deaths] as deaths
join [covid_analysis].[dbo].[covid_vacs] as vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date


--total vacsinated population
select deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population,
	vacs.new_vaccinations,
	sum(cast(vacs.new_vaccinations as BIGINT)) 
		over (partition by deaths.location order by deaths.location, deaths.date) as totalVacsPerCountry
FROM [covid_analysis].[dbo].[covid_deaths] as deaths
join [covid_analysis].[dbo].[covid_vacs] as vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
order by totalVacsPerCountry desc;

--
with popVac(continent, 
	location,
	date,
	population,
	new_vaccinations,
	totalVacsPerCountry)
as 
(
select deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population,
	vacs.new_vaccinations,
	sum(cast(vacs.new_vaccinations as BIGINT)) 
		over (partition by deaths.location order by deaths.location, deaths.date) as totalVacsPerCountry
FROM [covid_analysis].[dbo].[covid_deaths] as deaths
join [covid_analysis].[dbo].[covid_vacs] as vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
)
select *,totalVacsPerCountry/population*100 as percentage
from popVac
order by 2, 3
