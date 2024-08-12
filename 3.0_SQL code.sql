Create database covid1;
Use covid1;

#view the two tables imported through python
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as death_rate
from deaths
where continent is not null;


#select needed columns only
Select location,date,population,total_cases,new_cases,total_deaths,new_deaths
from deaths;

#Total cases vs total deaths and death rate
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_rate
from deaths
where continent ='Africa'
order by 1,2 asc;

#total cases vs population and infection rate
Select location,date,population, total_cases,round((total_cases/population)*100, 2) as infection_rate
from deaths
where continent ='Africa'
order by 1,2 asc;

#countries with highest infection rates
Select location,population, max(total_cases),round(max(total_cases/population)*100, 2) as infection_rate
from deaths
group by location,population
order by 4 desc;

#countries with the highest death rate per population

Select location,population, max(total_deaths),round(max(total_deaths/population)*100, 2) as deathrate
from deaths
group by location,population
order by 4 desc;


#infection rate per country

Select location,population,
max(total_cases) as highest_number_cases,round(max(total_cases/population)*100, 2) as infection_rate
from deaths
where continent is not null
group by location,population
order by 4 desc;

#daily infection rate per country
Select location,population,
max(total_cases) as highest_number_cases, date, round(max(total_cases/population)*100, 2) as infection_rate
from deaths
where continent is not null
group by location,population, date
order by 1 ;


#continent data

#death count
Select location, sum(new_deaths) total_deaths
from deaths
where continent is null and  location not in ('International', 'world','European Union')
group by location
order by 2 desc;

#infection rate per country

Select location,population,
max(total_cases) as highest_number_cases,round(max(total_cases/population)*100, 2) as infection_rate
from deaths
where continent is not null
group by location,population
order by 4 desc;


Select location,population,
max(total_cases),round(max(total_cases/population)*100, 2) as infection_rate,
max(total_deaths),round(max(total_deaths/population)*100, 2) as deathrate
from deaths
where continent is null and  location !='International'
group by location,population
order by 2 desc;

#join the two tables
Select d.continent, d.location,d.date,d.population,v.total_vaccinations,v.new_vaccinations
From deaths d
join
vaccinations v
on d.location=v.location
and d.date=v.date;

#rolling count

Select d.continent, d.location,d.date,d.population,v.total_vaccinations, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.date) as count
From deaths d
join
vaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not  null
order by 2,3;

#population vs vaccination

Select *,round((count/population)*100,2) as percent_vaccinated
from (Select d.continent, d.location,d.date,d.population,v.total_vaccinations, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.date) as count
From deaths d
join
vaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not  null and d.continent ='Africa'
order by 2,3)a;

#OR

with cte1 as
(Select d.continent, d.location,(d.date),d.population,v.total_vaccinations, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.date) as count
From deaths d
join
vaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not  null and  d.continent='Africa'
order by 2,3)
Select*,round((count/population)*100,2) as percent_vaccinated
from cte1;

Select location, month,avg(round((count/population)*100,2)) as percent_vaccinated
from (Select d.continent, d.location,substring(d.date,1,7) as month,d.population,
sum(v.new_vaccinations) over (partition by d.location order by substring(d.date,1,7)) as count
From deaths d
join
vaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not  null
order by 2,3)a
group by location,month;


