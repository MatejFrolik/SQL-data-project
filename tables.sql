-- Vytvoření potřebných tabulek pro zodpovězení výzkumných otátek. 

-- Vytvoření tabulky pro czechia_price a potřebné sloupce

CREATE OR REPLACE TABLE czechia_price_assist AS (
	SELECT cpc.name AS foodstuff_name , year(cp.date_from) AS price_year, 
        round(avg(cp.value),1) cost, cpc.price_value, cpc.price_unit 
	FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc ON cpc.code = cp.category_code 
	WHERE year(cp.date_from) BETWEEN 2006 AND 2018
	GROUP BY year(cp.date_from), cpc.name
);


-- Vytvoření tabulky pro czechia_payroll a potřebné sloupce

CREATE OR REPLACE TABLE czechia_payroll_assist AS (
	SELECT cpib.name AS branch_name , cp.payroll_year , round(avg(cp.value),0) AS salary
	FROM czechia_payroll cp 
	LEFT JOIN czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code 
	WHERE cp.value_type_code = 5958 AND cp.payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.payroll_year, cpib.name 
);

-- Vytvoření tabulky pro economies a countrie a potřebné sloupce

CREATE OR REPLACE TABLE czechia_gdp_assist AS (
	SELECT c.country, e.gdp , e.`year`  AS gdp_year
	FROM economies e
	LEFT JOIN countries c ON e.country = c.country 
	WHERE c.country LIKE 'Czech Republic' AND e.`year` BETWEEN 2006 AND 2018

);


-- Vytvoření finální tabulky pro odpovězení otázek

CREATE OR REPLACE TABLE t_Matej_Frolik_project_SQL_primary_final AS (
	SELECT *
	FROM assist2 AS  a2
	JOIN assist1 AS a1 ON a1.price_year = a2.payroll_year
	JOIN assist3 AS a3 ON a3.gdp_year = a1.price_year 
);
SELECT * FROM t_Matej_Frolik_project_SQL_primary_final ;

-- Hodnoty null u branch_name značí úhrn za všechna odvětví jednotlivý rok

-- Vytvoření finální tabulky č.2 pro informace o dalších státech

CREATE OR REPLACE TABLE t_Matej_Frolik_project_SQL_secondary_final AS (
SELECT c.*, e.country AS eco_country, e.`year` , e.GDP, e.population eco_population, e.gini 
FROM countries c 
LEFT JOIN economies e ON c.country = e.country