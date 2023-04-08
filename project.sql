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
-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, 
-- pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

--   Tabulka zahrnující vše potřebné: 
--  		1. Otázka: czechia_payroll(value,industry_branch code,payroll_year),
--  				   czechia_payroll_industry_branch(calculation, unit, value_type)
--  		   TODO - součet/průměr mezd za jednotlivý rok, roztřídit podle kategorií,
-- 	    	          seřadit podle roku nebo podle mzdy
--  		2. Otázka: czechia_payroll(value,payroll_year,), czechia_price(
--  				   id, value, category_code, date_from(to)), czechia_price_category(
--                     code, name, price_value, price_unit)
-- 		       TODO - první srovnatelné období bude rok 2006 a poslední bude rok 2018,
-- 				      z těhle let zjistit prumernou cenu a prumernou mzdu a vydělit mezi sebou,
-- 				      tím získáme počet litrů a kg za jednotlivé roky 
--  		3. Otázka: czechia_price(id, value, category_code, date_from(to),
--  				   czechia_price_category(code, name)
-- 		       TODO - zjistit prumernou cenu za jednotlivé kategorie potravin za jednotlivé roky, 
-- 				      zjistit jednotlivé narusty cen mezi roky, všechny nárůsty sečíst, 
-- 				      zjistit celkovou cenu za jeden rok, za druhý rok, odečíst od sebe druhý a 
-- 				      první rok, zjistit kolik je jedno procento z první ceny, vydělit odečtenou 
-- 				      hodnotu se zjistenim jednim procentem a tohle je narust v procentech
--  		4. Otázka: czechia_payroll(value, payroll_year),
--  				   czechia_price(id, value, date_from(to)
-- 		       TODO - zjistit to co v minulé otázce pro roky od 2006 do 2018, ale navíc i 
-- 				      pro mzdy, o kolik je X větší než Y - (x-y)/y*100
--  		5. Otázka: czechia_payroll(value, payroll_year), czeachia_price(id, value, 
-- 				       date_from(to)), economies(year, GDP), countries(country)
-- 		       TODO - zjistit meziroční nárusty GDP v procentech a porovnat to s 
-- 				      meziročníma nárůstama v procentech u potravin a mzdách

