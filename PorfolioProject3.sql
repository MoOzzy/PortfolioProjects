/* Project using JOINS by Osvaldo Morales
	In this project I use JOINS in order to pull data from two tables. Table 1 has the measurement from 1-10 
	of self reported satisfaction per year for each country listed. Table 2 measures the GINI score for each country
	which is the number assigned depending how how much inequlity there is in that country. The bigger the score
	the bigger the inequality.
Source of data: https://ourworldindata.org/grapher/happiness-cantril-ladder 
				https://ourworldindata.org/grapher/inequality-before-and-after-taxes-and-transfers-thewissen-et-al-data?tab=chart
*/

SELECT * FROM inequality$

SELECT * FROM happiness$

--Combining both tables
SELECT h.Entity, h.Year, h.[Life satisfaction in Cantril Ladder (World Happiness Report 2022],
		i.[Gini equivalised disposable household income entire pop (Incomes],
		i.[Gini equivalised market household income entire pop (Incomes acr]
FROM happiness$ h
JOIN inequality$ i ON h.Entity = i.Entity AND h.Year = i.Year

--This finds the average life satisfaction and Gini score for each country
--Note: Using the function AVG() works too but I want to showcase as many functions as possible
SELECT  
	h.Entity, 
	SUM(h.[Life satisfaction in Cantril Ladder (World Happiness Report 2022])/COUNT(h.Entity) as avg_satisfaction,
	SUM(i.[Gini equivalised disposable household income entire pop (Incomes])/COUNT(h.ENTITY) as avg_disposable,
	SUM(i.[Gini equivalised market household income entire pop (Incomes acr])/COUNT(h.ENTITY) as avg_market
FROM happiness$ h
JOIN inequality$ i ON h.Entity = i.Entity AND h.Year = i.Year
GROUP BY h.Entity
ORDER BY 2 DESC
 