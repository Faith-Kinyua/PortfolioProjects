SELECT*
FROM PortfolioProjects..CovidDeaths
WHERE continent is not Null
ORDER BY 3,4

SELECT*
FROM PortfolioProjects..CovidVaccinations
ORDER BY 3,4


--- Select The Data I Am Going To Use---

SELECT Location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2


---Looking at Total Cases vs Total Deaths in Kenya---
---Shows the likehood of dying if you contract Covid in Kenya---

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%Kenya%'
ORDER BY 1,2

---Looking at Total Cases vs Population in Kenya---
---Shows what percentage got covid in Kenya---

SELECT Location, date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%Kenya%'
ORDER BY 1,2

---Looking at Countries with the highest Infection Rate Compared to Population---

SELECT Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProjects..CovidDeaths
GROUP BY Location,population
ORDER BY InfectedPercentage DESC


---Looking at Countries With the Highest Deaths Count per Population---

SELECT Location,MAX(Cast(total_deaths As INT)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not Null
GROUP BY Location
ORDER BY TotalDeathCount DESC

---Breakign this down by continent---
---Showing continents with the highest death count per population---

SELECT continent ,MAX(Cast(total_deaths As INT)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is Not Null
GROUP BY Continent
ORDER BY TotalDeathCount DESC

---Looking at Total cases and Total deaths per day globally---

SELECT date,SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths as INT)) as Total_Deaths,SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent is not Null
GROUP BY date
ORDER BY 1,2

---Looking at total cases and deaths globally---

SELECT SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths as INT)) as Total_Deaths,SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent is not Null
---GROUP BY date
ORDER BY 1,2

---Total cases and Deaths in Kenya---

SELECT Sum(new_cases) as Total_cases,Sum(CAST(new_deaths as INT)) as Total_Deaths,Sum(CAST(new_deaths as INT))/Sum(new_cases)*100 as Deathpercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%Kenya%'

---Joining the covid vaccinations and covid deaths table on location and date---

SELECT*
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date

---Looking at population vs total vaccinations---

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent is not Null
ORDER BY 2,3

---Use CTE---

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent is not Null)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

---TEMP Table---

DROP TABLE if exists #VaccinatedPeoplePercentege
CREATE TABLE #VaccinatedPeoplePercentege
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)
INSERT INTO #VaccinatedPeoplePercentege
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
---WHERE Dea.continent is not Null
SELECT*, (RollingPeopleVaccinated/population)*100
FROM #VaccinatedPeoplepercentege

---People vaccinated in Kenya vs the population---

SELECT Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as KenyansVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.location like '%Kenya%'
ORDER BY 2,3

---USE CTE---

WITH KEPopvsVac (Location, Date, Population, new_vaccinations,KenyansVaccinated)
as
(SELECT Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as KenyansVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.location like '%Kenya%')
SELECT*, (KenyansVaccinated/population)*100
FROM KEPopvsVac

---Temp table---

DROP TABLE if exists #VaccinatedPeoplePercentege
CREATE TABLE #KenyaVaccinatedPeoplePercentege
(Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
KenyansVaccinated numeric)
INSERT INTO #KenyaVaccinatedPeoplePercentege
SELECT Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as KenyansVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.location like '%Kenya%'
SELECT*, (KenyansVaccinated/population)*100
FROM #KenyaVaccinatedPeoplePercentege


---Creating view to store data for visualization---

CREATE VIEW VaccinatedPeoplePercentege as 
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent is not Null


CREATE VIEW Kenyacasesvsdeaths as
SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%Kenya%'


CREATE VIEW Kenyacasesvspopulation as
SELECT Location, date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%Kenya%'

CREATE VIEW Kenyansvaccinated as 
SELECT Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, 
Dea.date) as KenyansVaccinated
FROM PortfolioProjects..CovidDeaths Dea
JOIN PortfolioProjects..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.location like '%Kenya%'



