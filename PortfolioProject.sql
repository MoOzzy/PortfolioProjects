/*Data Exploration project by Osvaldo Morales
Data Source: Hannah Ritchie, Pablo Rosado, Edouard Mathieu, Max Roser (2022) Our World in Data Energy 
	           https://ourworldindata.org/explorers/energy?tab=chart&facet=none&country=USA~GBR~CHN~OWID_WRL~IND~BRA~ZAF&Total+or+Breakdown=Select+a+source&Select+a+source=Fossil+fuels&Energy+or+Electricity=Electricity+only&Metric=Annual+generation


The following data set shows the solar energy and fossil fuel consumption as well as greenhouse gas emissions
throughtout the past 20 years of the United States
Values in TWh
*/

DELETE FROM PortfolioProject..energy WHERE greenhouse_gas_emissions is NULL; --Data from 1999 and behind is NULL

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Calculates the percentage change compared to the previous year
SELECT 
		country, year, solar_consumption, LAG(solar_consumption) OVER (ORDER BY year) AS previous_solar,
		cast(IsNULL(solar_consumption, '0') as numeric (18,3))-cast(IsNULL(LAG(solar_consumption)OVER (ORDER BY year),'0') as numeric (18,3)) as diff_of_solar,
		((cast(solar_consumption as numeric(18,3))-LAG(solar_consumption) OVER (ORDER BY year))/(NULLif(ABS(LAG(solar_consumption) OVER (ORDER BY year)),0)))*100 as solar_ratio_change,
		LAG(fossil_fuel_consumption) OVER (ORDER BY year) AS previous_fossil,
		cast(IsNULL(fossil_fuel_consumption, '0') as numeric (18,3))-cast(IsNULL(LAG(fossil_fuel_consumption)OVER (ORDER BY year),'0') as numeric (18,3)) as diff_of_fossil,
		((cast(fossil_fuel_consumption as numeric(18,3))-LAG(fossil_fuel_consumption) OVER (ORDER BY year))/(NULLif(ABS(LAG(fossil_fuel_consumption) OVER (ORDER BY year)),0)))*100 as fossil_ratio_change,
		fossil_fuel_consumption, greenhouse_gas_emissions, population
		
FROM PortfolioProject..energy  
-----------------------------------------------------------------------------------------------------------------------------------------
--Calculates the amount of solar energy, fossil fuel, and greenhouse gas emission per person in the United States in MWh
-- 1 TWh = 1,000,000 MWh
-----------------------------------------------------------------------------------------------------------------------------------------
SELECT
(solar_consumption/population)*1000000 as solar_populartion,
(fossil_fuel_consumption/population)*1000000 as fossil_population,
(greenhouse_gas_emissions/population)*1000000 as green_population
FROM PortfolioProject..energy

-----------------------------------------------------------------------------------------------------------------------------------
--Using the correlation formula r = sum((x-x_bar)*(y-y_bar))/sqrt(sum((x-x_bar)^2)*sum((y-y_bar)^2))
--Method = Pearson
----------------------------------------------------------------------------------------------------------------------------------

--solar energy consumtion and greenhouse emissions correlation

WITH mean AS (
	SELECT 
		solar_consumption, greenhouse_gas_emissions,
		AVG(cast(solar_consumption as numeric(18,3))) OVER() as solar_mean,
		AVG(cast(greenhouse_gas_emissions as numeric(18,3))) OVER() as green_mean
	FROM PortfolioProject..energy
	),
	covariance AS (
	SELECT 
		SUM((cast(solar_consumption as numeric(18,3))-solar_mean)*(cast(greenhouse_gas_emissions as numeric(18,3))-green_mean)) as covariance
	FROM mean
	),
	variance AS (
	SELECT 
		SUM(POWER(cast(solar_consumption as numeric(18,3))-solar_mean, 2)) as solar_var,
		SUM(POWER(cast(greenhouse_gas_emissions as numeric(18,3))-green_mean, 2)) as green_var
	FROM mean
	),
	standard_dev AS (
	SELECT
		POWER(solar_var, 0.5) as solar_stand,
		POWER(green_var, 0.5) as green_stand
	FROM variance
	)
SELECT  
	*, 
	covariance/(solar_stand*green_stand) as solar_greenhouse_correlation
FROM mean, covariance, variance, standard_dev

----------------------------------------------------------------------------------------------------------------------------------------------
--fossil fuel consumption and greehouse gas emissions correlation

WITH mean AS (
	SELECT 
		fossil_fuel_consumption, greenhouse_gas_emissions,
		AVG(cast(fossil_fuel_consumption as numeric(18,3))) OVER() as fossil_mean,
		AVG(cast(greenhouse_gas_emissions as numeric(18,3))) OVER() as green_mean
	FROM PortfolioProject..energy
	),
	covariance AS (
	SELECT 
		SUM((cast(fossil_fuel_consumption as numeric(18,3))-fossil_mean)*(cast(greenhouse_gas_emissions as numeric(18,3))-green_mean)) as covariance
	FROM mean
	),
	variance AS (
	SELECT 
		SUM(POWER(cast(fossil_fuel_consumption as numeric(18,3))-fossil_mean, 2)) as fossil_var,
		SUM(POWER(cast(greenhouse_gas_emissions as numeric(18,3))-green_mean, 2)) as green_var
	FROM mean
	),
	standard_dev AS (
	SELECT
		POWER(fossil_var, 0.5) as fossil_stand,
		POWER(green_var, 0.5) as green_stand
	FROM variance
	)
SELECT 
	*, 
	covariance/(fossil_stand*green_stand) as fossil_greenhouse_correlation
FROM mean, covariance, variance, standard_dev
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--solar and fossil fuel correlation
WITH mean AS (
	SELECT 
		fossil_fuel_consumption, solar_consumption,
		AVG(cast(fossil_fuel_consumption as numeric(18,3))) OVER() as fossil_mean,
		AVG(cast(solar_consumption as numeric(18,3))) OVER() as solar_mean
	FROM PortfolioProject..energy
	),
	covariance AS (
	SELECT 
		SUM((cast(fossil_fuel_consumption as numeric(18,3))-fossil_mean)*(cast(solar_consumption as numeric(18,3))-solar_mean)) as covariance
	FROM mean
	),
	variance AS (
	SELECT 
		SUM(POWER(cast(fossil_fuel_consumption as numeric(18,3))-fossil_mean, 2)) as fossil_var,
		SUM(POWER(cast(solar_consumption as numeric(18,3))-solar_mean, 2)) as solar_var
	FROM mean
	),
	standard_dev AS (
	SELECT
		POWER(fossil_var, 0.5) as fossil_stand,
		POWER(solar_var, 0.5) as solar_stand
	FROM variance
	)
SELECT 
	*,
	covariance/(fossil_stand*solar_stand) as fossil_solar_correlation
FROM mean, covariance, variance, standard_dev

	