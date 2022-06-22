--By Osvaldo Morales
--The following project uses simple operations to calculate rate changes compared to last year
--as well as performing a rolling sum to caculate the total amount of energy used up to that year. 

--The data set shows the annual solar change compared to the previous year. The solar enegy is measured in TWh
--Data set source: BP Statistical Review of World Energy(2022) https://www.bp.com/en/global/corporate/energy-economics/statistical-review-of-world-energy.html

SELECT * FROM..solar$

--Shows the total amount of Solar Energy Used by country
SELECT 
SUM(Solar) as sum_solar_energy_country, Entity
FROM solar$
WHERE Code is not NUll
GROUP BY Entity
ORDER BY 1 DESC

--Shows the percentage change comapared to the previous year
SELECT 
Year, Entity, Solar,
((Solar-LAG(Solar) OVER (PARTITION BY Entity ORDER BY Year))/(NULLif(ABS(LAG(Solar) OVER (PARTITION BY Entity ORDER BY Year)),0)))*100 as solar_change
FROM ..solar$
WHERE Code is not NUll
GROUP BY  Entity, Year, Solar
ORDER BY 2;

--Shows the total amount of energy by continent or organization
SELECT 
SUM(Solar) as sum_solar_energy, Entity
FROM solar$
WHERE Code is NUll
GROUP BY Entity
ORDER BY 1 DESC;

--rolling sum by country
SELECT 
Year, SUM(Solar) OVER (PARTITION BY ENTITY ORDER BY Year) as sum_solar_energy_country, Entity
FROM solar$
WHERE Code is not NUll
GROUP BY Entity, Year, Solar
ORDER BY 3 

--rolling sum by continent or organization 
SELECT 
Year, SUM(Solar) OVER (PARTITION BY ENTITY ORDER BY Year) as sum_solar_energy_country, Entity
FROM solar$
WHERE Code is NUll
GROUP BY Entity, Year, Solar
ORDER BY 3 
