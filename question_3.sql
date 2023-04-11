-- Zodpovězení otázky č. 3 - Která kategorie potravin zdražuje nejpomaleji 
--                           (je u ní nejnižší percentuální meziroční nárůst)?

CREATE OR REPLACE VIEW interannual_growth AS(
SELECT t.foodstuff_name, t.price_year, t2.price_year AS prew_year, t.cost, t2.cost cost_prew,
	   round(((t.cost - t2.cost) / t2.cost * 100), 2) AS growth
FROM t_Matej_Frolik_project_SQL_primary_final t
JOIN t_Matej_Frolik_project_SQL_primary_final t2 
	ON t.foodstuff_name = t2.foodstuff_name
	AND t.price_year = t2.price_year + 1
GROUP BY foodstuff_name, price_year);

SELECT foodstuff_name, sum(growth),
CASE 
	WHEN sum(growth) < 10 THEN 'nízky meziroční nárůst'
	WHEN sum(growth) < 40 THEN 'střední meziroční nárůst'
	ELSE 'vysoký meziroční nárůst'
END AS interannual_prices_growth
FROM interannual_growth
GROUP BY foodstuff_name
ORDER BY sum(growth); --dotaz pro rozdělení nárůstů

SELECT foodstuff_name, sum(growth)
FROM interannual_growth
GROUP BY foodstuff_name
ORDER BY sum(growth);