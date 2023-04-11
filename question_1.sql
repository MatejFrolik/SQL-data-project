-- Zodpovězení otázky č. 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

SELECT t.branch_name, t.payroll_year, t2.payroll_year AS year_prew, 
	   round( (t.salary - t2.salary) / t2.salary * 100, 1) AS salary_growth_percent
FROM t_Matej_Frolik_project_SQL_primary_final t
JOIN t_Matej_Frolik_project_SQL_primary_final t2 
	ON t.branch_name = t2.branch_name
	AND t.payroll_year = t2.payroll_year + 1
GROUP BY t.payroll_year, t2.payroll_year, t.branch_name
ORDER BY t.branch_name, t.payroll_year;

WITH salary_growth AS(
SELECT t.branch_name, t.payroll_year, t2.payroll_year AS year_prew, 
	   round( (t.salary - t2.salary) / t2.salary * 100, 1) AS salary_growth_percent
FROM t_Matej_Frolik_project_SQL_primary_final t
JOIN t_Matej_Frolik_project_SQL_primary_final t2 
	ON t.branch_name = t2.branch_name
	AND t.payroll_year = t2.payroll_year + 1
GROUP BY t.payroll_year, t2.payroll_year, t.branch_name
HAVING salary_growth_percent < 0
ORDER BY t.branch_name, t.payroll_year)
SELECT DISTINCT (branch_name)
FROM salary_growth;