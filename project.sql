'''
project.sql: První projekt do Engeto Online Datové akademie.
author: Matěj Frolík
email: matejfrolik1@seznam.cz
discord: Mates F.#4204
'''

'Budu rád za jakýkoliv + a - mého projektu, abych si ho mohl dostatečně vylepšit v rámci rychlosti běhu dotazů atd.'

-- Tabulky:
-- t_{jmeno}_{prijmeni}_project_SQL_primary_final 
-- (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) 
-- t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech)

-- Výzkumné otázky:
-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první 
-- a poslední srovnatelné období v dostupných datech cen a mezd?
-- 3. Která kategorie potravin zdražuje nejpomaleji 
-- (je u ní nejnižší percentuální meziroční nárůst)?
-- 4. Existuje rok, ve kterém byl meziroční nárůst 
-- cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, 
-- pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

-- Tabulky a TODO list:
-- 1. Otázka: czechia_payroll(value,industry_branch code,payroll_year),
-- czechia_payroll_industry_branch(calculation, unit, value_type)
-- TODO - součet/průměr mezd za jednotlivý rok, roztřídit podle kategorií,
-- seřadit podle roku nebo podle mzdy
-- 2. Otázka: czechia_payroll(value,payroll_year,), czechia_price(value, category_code, 
-- date_from(to)), czechia_price_category(code, name, price_value, price_unit)
-- TODO - první srovnatelné období bude rok 2006 a poslední bude rok 2018,
-- z těhle let zjistit prumernou cenu a prumernou mzdu a vydělit mezi sebou,
-- tím získáme počet litrů a kg za jednotlivé roky 
-- 3. Otázka: czechia_price(value, category_code, date_from(to),
-- czechia_price_category(code, name)
-- TODO - zjistit prumernou cenu za jednotlivé kategorie potravin za jednotlivé roky, 
-- zjistit jednotlivé narusty cen mezi roky, všechny nárůsty sečíst, 
-- zjistit celkovou cenu za jeden rok, za druhý rok, odečíst od sebe druhý a 
-- první rok, zjistit kolik je jedno procento z první ceny, vydělit odečtenou 
-- 4. Otázka: czechia_payroll(value, payroll_year, payroll_quarter),
-- czechia_price(id, value, date_from(to)
-- TODO - zjistit to co v minulé otázce pro roky od 2006 do 2018, ale navíc i 
-- pro mzdy, o kolik je X větší než Y - (x-y)/y*100
-- 5. Otázka: czechia_payroll(value, payroll_year), czeachia_price(value, 
-- date_from(to)), economies(year, GDP), countries(country)
-- TODO - zjistit meziroční nárusty GDP v procentech a porovnat to s 
-- meziročníma nárůstama v procentech u potravin a mzdách

-- 1. Vytvoření tabulek pro zodpovězení otázek:
-- Postupné vytvoření tří tabulek, z které pak vytvoříme finální verzi. 
-- Tabulky budou obsahovat souhrné roky pro všechny tři v rozmezí 2006 až 2018.

-- Vytvoření tabulky pro czechia_price a potřebné sloupce

CREATE OR REPLACE TABLE assist1 AS (
	SELECT cpc.name AS foodstuff_name , year(cp.date_from) AS price_year, 
        round(avg(cp.value),1) cost, cpc.price_value, cpc.price_unit 
	FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc ON cpc.code = cp.category_code 
	WHERE year(cp.date_from) BETWEEN 2006 AND 2018
	GROUP BY year(cp.date_from), cpc.name
);


-- Vytvoření tabulky pro czechia_payroll a potřebné sloupce

CREATE OR REPLACE TABLE assist2 AS (
	SELECT cpib.name AS branch_name , cp.payroll_year , round(avg(cp.value),0) AS salary
	FROM czechia_payroll cp 
	LEFT JOIN czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code 
	WHERE cp.value_type_code = 5958 AND cp.payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.payroll_year, cpib.name 
);

-- Vytvoření tabulky pro economies a countrie a potřebné sloupce

CREATE OR REPLACE TABLE assist3 AS (
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
);


-- Zodpovězení otázky č. 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- Z daného dotazu dokážeme zjistit, že v 15 z 19 odvětví byl alespoň jeden rok, kdy mzda klesala

SELECT t.branch_name, t.payroll_year, t2.payroll_year AS year_prew, 
	   round( (t.salary - t2.salary) / t2.salary * 100, 1) AS salary_growth_percent
FROM t_Matej_Frolik_project_SQL_primary_final t
JOIN t_Matej_Frolik_project_SQL_primary_final t2 
	ON t.branch_name = t2.branch_name
	AND t.payroll_year = t2.payroll_year + 1
GROUP BY t.payroll_year, t2.payroll_year, t.branch_name
ORDER BY t.branch_name, t.payroll_year;

-- Zopovězení otázky č. 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první 
--                          a poslední srovnatelné období v dostupných datech cen a mezd?
-- Tímto dotazem získáme přehled, kolik je možno si koupit l mléka a kg chleba za jednotlivé roky

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


-- Zodpovězení otázky č. 3 - Která kategorie potravin zdražuje nejpomaleji 
--                           (je u ní nejnižší percentuální meziroční nárůst)?
-- Zodpovězení otázky pomocí pohledu

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
ORDER BY sum(growth); --dotaz pro kategorii s nejnižším meziročním nárůstem

-- Zodpovězení otázky č. 4 - 4. Existuje rok, ve kterém byl meziroční nárůst 
--                              cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- Z dotazu otázky č. 1. vytvoříme view

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
GROUP BY sg.payroll_year, ig.price_year; --použijeme pohled z předchozí otázky a dotazem si zobrazíme rozdíly 

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
GROUP BY sg.payroll_year, ig.price_year, gg.gdp_year; -- spojení všech tří pohledů na zodpovězení otázky
