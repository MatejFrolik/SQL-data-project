'''
project.sql: První projekt do Engeto Online Datové akademie.
author: Matěj Frolík
email: matejfrolik1@seznam.cz
discord: Mates F.#4204
'''


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
-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

-- Tabulky a TODO list:
-- 1. Otázka: czechia_payroll(value,industry_branch code,payroll_year),
-- czechia_payroll_industry_branch(calculation, unit, value_type)
-- TODO - součet/průměr mezd za jednotlivý rok, roztřídit podle kategorií,
-- seřadit podle roku nebo podle mzdy
-- 2. Otázka: czechia_payroll(value,payroll_year,), czechia_price(value, category_code, date_from(to)), czechia_price_category(
-- code, name, price_value, price_unit)
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

-- Hodnoty null u industry branch code jsou uhrny za vsechny odvetvi

-- 1. Vytvoření tabulek pro zodpovězení otázek:
-- Postupné vytvoření tří tabulek, z které pak vytvoříme finální verzi. 
-- Tabulky budou obsahovat souhrné roky pro všechny tři v rozmezí 2006 až 2018.

-- Vytvoření tabulky pro czechia_price a potřebné sloupce

CREATE OR REPLACE TABLE assist1 AS (
	SELECT cpc.name AS foodstuff_name , year(cp.date_from) AS price_year, round(avg(cp.value),1) cost, cpc.price_value, cpc.price_unit 
	FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc ON cpc.code = cp.category_code 
	WHERE year(cp.date_from) BETWEEN 2006 AND 2018
	GROUP BY year(cp.date_from), cpc.name
);
SELECT * FROM assist1;


-- Vytvoření tabulky pro czechia_payroll a potřebné sloupce

CREATE OR REPLACE TABLE assist2 AS (
	SELECT cpib.name AS branch_name , cp.payroll_year , round(avg(cp.value),0) AS salary
	FROM czechia_payroll cp 
	LEFT JOIN czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code 
	WHERE cp.value_type_code = 5958 AND cp.payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.payroll_year, cpib.name 
);
SELECT * FROM assist2;

-- Vytvoření tabulky pro economies a countrie a potřebné sloupce

CREATE OR REPLACE TABLE assist3 AS (
	SELECT c.country, e.gdp , e.`year`  AS gdp_year
	FROM economies e
	LEFT JOIN countries c ON e.country = c.country 
	WHERE c.country LIKE 'Czech Republic' AND e.`year` BETWEEN 2006 AND 2018

);
SELECT * FROM assist3;

-- Vytvoření finální tabulky pro odpovězení otázek

REATE OR REPLACE TABLE t_Matej_Frolik_project_SQL_primary_final AS (
	SELECT *
	FROM assist2 AS  a2
	JOIN assist1 AS a1 ON a1.price_year = a2.payroll_year
	JOIN assist3 AS a3 ON a3.gdp_year = a1.price_year 
);
SELECT * FROM t_Matej_Frolik_project_SQL_primary_final ;

-- Vytvoření finální tabulky č.2 pro informace o dalších státech

CREATE OR REPLACE TABLE t_Matej_Frolik_project_SQL_secondary_final AS (
SELECT c.*, e.country AS eco_country, e.`year` , e.GDP, e.population eco_population, e.gini 
FROM countries c 
LEFT JOIN economies e ON c.country = e.country
);
SELECT * FROM t_Matej_Frolik_project_SQL_secondary_final ;
