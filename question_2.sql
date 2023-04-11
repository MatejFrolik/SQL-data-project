-- Zopovězení otázky č. 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první 
--                          a poslední srovnatelné období v dostupných datech cen a mezd?

WITH max_min AS(
SELECT min(salary), max(salary)
FROM t_Matej_Frolik_project_SQL_primary_final 
WHERE branch_name IS NULL
)
SELECT foodstuff_name, price_year, cost, 
	round((max(salary) / cost), 2) AS milk_bread_quantity, price_value, price_unit 
FROM t_Matej_Frolik_project_SQL_primary_final
WHERE foodstuff_name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový') 
	  AND branch_name IS NULL 
GROUP BY foodstuff_name, price_year;