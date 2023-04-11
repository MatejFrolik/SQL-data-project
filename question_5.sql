-- Zodpovězení otázky č. 5 - Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, 
--                           pokud HDP vzroste výrazněji v jednom roce, 
--                           projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

CREATE OR REPLACE VIEW gdp_growth AS (
SELECT t.gdp_year, t2.gdp_year AS prew_year,
	   round( (t.gdp - t2.gdp) / t2.gdp * 100, 1 ) AS gdp_growth_percent
FROM t_Matej_Frolik_project_SQL_primary_final t
JOIN t_Matej_Frolik_project_SQL_primary_final t2
	ON t.country = t2.country
	AND t.gdp_year = t2.gdp_year + 1
GROUP BY gdp_year); --vytvoření pohledu pro percentuální nárůst HDP v České republice


SELECT sg.payroll_year, 
	   avg(sg.salary_growth_percent) AS salary_percent_growth, 
	   avg(ig.growth) AS price_percent_growth, 
	   avg(gg.gdp_growth_percent) AS gdp_percent_growth
FROM salary_growth sg
JOIN interannual_growth ig ON sg.payroll_year = ig.price_year
JOIN gdp_growth gg ON gg.gdp_year = sg.payroll_year
GROUP BY sg.payroll_year, ig.price_year, gg.gdp_year; 