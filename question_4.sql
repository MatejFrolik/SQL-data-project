-- Zodpovězení otázky č. 4 - 4. Existuje rok, ve kterém byl meziroční nárůst 
--                              cen potravin výrazně vyšší než růst mezd (větší než 10 %)?


CREATE OR REPLACE VIEW salary_growth AS (
SELECT t.branch_name, t.payroll_year, t2.payroll_year AS year_prew, 
	   round( (t.salary - t2.salary) / t2.salary * 100, 1) AS salary_growth_percent
FROM t_Matej_Frolik_project_SQL_primary_final t
JOIN t_Matej_Frolik_project_SQL_primary_final t2 
	ON t.branch_name = t2.branch_name
	AND t.payroll_year = t2.payroll_year + 1
GROUP BY t.payroll_year, t2.payroll_year, t.branch_name
ORDER BY t.branch_name, t.payroll_year);

SELECT sg.payroll_year, avg(sg.salary_growth_percent), avg(ig.growth),
	   concat((avg(ig.growth)-avg(sg.salary_growth_percent)),' diff in %') AS difference
FROM salary_growth sg
JOIN interannual_growth ig ON sg.payroll_year = ig.price_year
GROUP BY sg.payroll_year, ig.price_year;

WITH foodstuff_salary_growth AS(
SELECT sg.payroll_year, avg(sg.salary_growth_percent) AS sal_growth, avg(ig.growth) AS food_growth,
	   concat((avg(ig.growth)-avg(sg.salary_growth_percent)),' diff in %') AS difference
FROM salary_growth sg
JOIN interannual_growth ig ON sg.payroll_year = ig.price_year
GROUP BY sg.payroll_year, ig.price_year)
SELECT DISTINCT(payroll_year)
FROM foodstuff_salary_growth
WHERE(food_growth-sal_growth)>10;