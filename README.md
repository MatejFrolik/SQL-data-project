# Projekt ENGETO ACADEMY - datová analýzy  


  
Odkaz na můj **Linkedl** [ZDE](https://www.linkedin.com/in/matěj-frol%C3%ADk-183812230/).


----

## Úvod do projektu/zadání projektu


Na analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jsme se dohodli, že se pokusíme odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Úkolem je připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

K projektu jsou použity datové sady z Portálu otevřených dat ČR.

---
## Výzkumné otázky

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?  

2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?  

3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?  

4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?  

5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?  


---

## Průběh projektu
1. V první fázi projektu je třeba si vytvořit dvě tabulky a to první tabulku s názvem **t_Matej_Frolik_project_SQL_primary_final**, kde získáme potřebné sloupce pro zodpovězení výzkumných otázek a druhou tabulku s názvem **t_Matej_Frolik_project_SQL_secondary_final**, která bude obsahovat data pro ostatní státy. K vytvoření první tabulky jsou vytvořeny tři pomocné tabulky (czechia_price_assist, czechia_payroll_assist a czechia_gdp_assist) ze kterých pak výsledná tabulky vychází. 

```
CREATE OR REPLACE TABLE czechia_price_assist AS (
	SELECT cpc.name AS foodstuff_name , year(cp.date_from) AS price_year, 
        round(avg(cp.value),1) cost, cpc.price_value, cpc.price_unit 
	FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc ON cpc.code = cp.category_code 
	WHERE year(cp.date_from) BETWEEN 2006 AND 2018
	GROUP BY year(cp.date_from), cpc.name
);

CREATE OR REPLACE TABLE czechia_payroll_assist AS (
	SELECT cpib.name AS branch_name , cp.payroll_year , round(avg(cp.value),0) AS salary
	FROM czechia_payroll cp 
	LEFT JOIN czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code 
	WHERE cp.value_type_code = 5958 AND cp.payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.payroll_year, cpib.name 
);

CREATE OR REPLACE TABLE czechia_gdp_assist AS (
	SELECT c.country, e.gdp , e.`year`  AS gdp_year
	FROM economies e
	LEFT JOIN countries c ON e.country = c.country 
	WHERE c.country LIKE 'Czech Republic' AND e.`year` BETWEEN 2006 AND 2018

);

CREATE OR REPLACE TABLE t_Matej_Frolik_project_SQL_primary_final AS (
	SELECT *
	FROM assist2 AS  a2
	JOIN assist1 AS a1 ON a1.price_year = a2.payroll_year
	JOIN assist3 AS a3 ON a3.gdp_year = a1.price_year 
);
SELECT * FROM t_Matej_Frolik_project_SQL_primary_final ;


CREATE OR REPLACE TABLE t_Matej_Frolik_project_SQL_secondary_final AS (
SELECT c.*, e.country AS eco_country, e.`year` , e.GDP, e.population eco_population, e.gini 
FROM countries c 
LEFT JOIN economies e ON c.country = e.country
```

2. U zodpovězení první otázky _Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?_ si nejprve necháme načíst procentuální růst nebo pokles mezd pro jednotlivé odvětví a roky a druhým dotazem vybere jen ty odvětví, ve kterých nám mzda alespoň jednou klesala, čímž, zjistíme, že v **15 odvětví** nám mzda ale jednou za dané období klesala. 

```
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
```
3. U zodpovězení druhé otázky _Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?_ si z naší tabulky necháme načíst přehled, kolik je možné si koupit litrů mléka a kilogramů chleba za jednotlivé roky. Z toho vyčteme, že např. u srovnání roků 2006 a 2018, je možné si v roce 2006 koupit za průměrný plat **1,192.25 kg chleba a 1,330.96 l mléka a v roce 2018 1,300.37 kg chleba a 1,590.36 l mléka**.

```
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
```

4. U zodpovězení třetí otázky _Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?_ si nejprve vytvoříme VIEW, pomocí kterého si poté výrazem CASE roztřídíme nárůsty jednotlivých kategorií potravin do tří skupin s nejnižším, středním a nejvyšším nárůstem. V dalším dotazu pak zjistíme, že potravina s nejnižším meziročním procentuálním nárůstem je **cukr krystalový**.

```
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
ORDER BY sum(growth); 

SELECT foodstuff_name, sum(growth)
FROM interannual_growth
GROUP BY foodstuff_name
ORDER BY sum(growth);
```

5. U zodpovězení čtvrté otázky _Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?_ si nejdříve vytvoříme VIEW. Pomocí něhož v druhém dotazu získáme procentuální rozdíl meziročního nárůstu mezd a cen potravin. Závěrečným dotazem pak zjistíme, že v **žádném roce nebyl nárůst cen potravin vyšší než 10% oproti nárůstu mezd.**

```
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
```

6. U poslední páté otázky _Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?_ si po vytvoření pomocného VIEW necháme načíst tabulky, kde máme porovnání procentuální nárůstu u cen potravin, mzdách a HDP. Ve srovnání pak vidíme, **že nárůst nebo pokles HDP nám pavidelně neovlivňuje nárůst či pokled mezd nebo cen potravin.**

```
CREATE OR REPLACE VIEW gdp_growth AS (
SELECT t.gdp_year, t2.gdp_year AS prew_year,
	   round( (t.gdp - t2.gdp) / t2.gdp * 100, 1 ) AS gdp_growth_percent
FROM t_Matej_Frolik_project_SQL_primary_final t
JOIN t_Matej_Frolik_project_SQL_primary_final t2
	ON t.country = t2.country
	AND t.gdp_year = t2.gdp_year + 1
GROUP BY gdp_year); 


SELECT sg.payroll_year, 
	   avg(sg.salary_growth_percent) AS salary_percent_growth, 
	   avg(ig.growth) AS price_percent_growth, 
	   avg(gg.gdp_growth_percent) AS gdp_percent_growth
FROM salary_growth sg
JOIN interannual_growth ig ON sg.payroll_year = ig.price_year
JOIN gdp_growth gg ON gg.gdp_year = sg.payroll_year
GROUP BY sg.payroll_year, ig.price_year, gg.gdp_year; 
```