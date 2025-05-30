SELECT fullvisitorid FROM all_sessions;
SELECT * FROM all_sessions; -- has fullvisitorid, v2productcategory
SELECT * FROM analytics;
SELECT DISTINCT * FROM sales_by_sku;

SELECT * FROM analytics
ORDER BY date;

SELECT DISTINCT fullvisitorid,* FROM analytics;

SELECT * FROM products p
JOIN sales_report sr ON p.sku=sr.productsku
JOIN sales_by_sku sbs ON sbs.productsku=sr.productsku


SELECT * FROM sales_report; -- has productsku
SELECT * FROM products;

SELECT * FROM analytics
WHERE revenue is NOT NULL
;

SELECT DISTINCT socialengagementtype, COUNT(*) FROM analytics
GROUP BY socialengagementtype

SELECT productsku FROM all_sessions;

SELECT * FROM all_sessions
ORDER BY date;

SELECT DISTINCT fullvisitorid, * FROM all_sessions
ORDER BY productsku;

--
SELECT * FROM allsession_analytics_combined;
SELECT * FROM all_sessions_clean;
SELECT * FROM analytics_clean;

--
-- Create table views of cleaned data for future use.
-- DROP VIEW all_sessions_clean;
CREATE OR REPLACE VIEW all_sessions_clean AS 
	SELECT 
		fullvisitorid
		, channelgrouping
		-- standardize missing data as 'N/A'
		, CASE WHEN country IN ('(not set)') THEN 'N/A'
			ELSE country END
		, CASE WHEN city IN ('not available in demo dataset', '(not set)') THEN 'N/A'
			ELSE city END
		-- money amounts are incorrectly encoded in the millions. These are recalculated and presented as floating point.
		, CAST (COALESCE (totaltransactionrevenue, 0) AS float4) / 1000000 AS totaltransactionrevenue
		, visitid
		, productsku
		-- Correct special characters and typos
		, CASE WHEN v2productname = '7&quot; Dog Frisbee' THEN 'Dog Frisbee' 
			ELSE v2productname END
		, CASE WHEN v2productcategory IN ('${escCatTitle}', '(not set)') THEN 'N/A'
			ELSE v2productcategory END
	FROM all_sessions
;

-- DROP VIEW analytics_clean;
CREATE OR REPLACE VIEW analytics_clean AS 
	SELECT 
		fullvisitorid
		-- I've decided to treat negative unit sales amounts as a typo and removed the negative.
		-- However, it may be correct to exclude these lines. 
		, CASE WHEN units_sold < 0 THEN ABS(units_sold) -- treat negative values as typos
			ELSE units_sold END
		-- money amounts are incorrectly encoded in the millions. These are recalculated and presented as floating point.
		, CAST(unit_price AS float4) / 1000000 AS unit_price -- reduce values to sensible amounts
		, bounces
	FROM analytics
	WHERE units_sold IS NOT NULL -- removes any units_sold with NULL value, ie no sales
	ORDER BY units_sold DESC
;

-- DROP VIEW allsession_analytics_combined;
CREATE OR REPLACE VIEW allsession_analytics_combined AS
	SELECT *
	FROM all_sessions_clean
	-- This join removes null value fullvisitorid lines, which may take out too many valid lines
	JOIN analytics_clean USING(fullvisitorid)
;




-- Question 1: Which cities and countries have the highest level of transaction revenues on the site?
SELECT country, SUM( totaltransactionrevenue)::float4 as TotalTransactionRevenue
FROM all_sessions_clean
GROUP BY country
ORDER BY SUM(totaltransactionrevenue) DESC
LIMIT 10;

SELECT city, SUM(totaltransactionrevenue)::float4 as TotalTransactionRevenue
FROM all_sessions_clean
GROUP BY city
ORDER BY SUM(totaltransactionrevenue) DESC
LIMIT 10;


-- Question 2: What is the average number of products ordered from visitors in each city and country
-- 
SELECT * FROM sales_report; -- has total_ordered per product
SELECT DISTINCT fullvisitorid, * FROM all_sessions; -- has country and city, fullvisitorid, productcategory
SELECT * FROM analytics; -- has units_sold, fullvisitorid

-- The average number of products ordered per country
SELECT country
	, AVG(units_sold)::numeric(5,2) AS avg_units_sold
FROM allsession_analytics_combined
GROUP BY country
ORDER BY avg_units_sold DESC
;

-- The average number of products ordered per city
SELECT city
	, AVG(units_sold)::numeric(5,2) AS avg_units_sold
FROM allsession_analytics_combined
GROUP BY city
ORDER BY avg_units_sold DESC
;

-- Question 3: Is there any pattern in the types (product categories) of products 
-- ordered from visitors in each city and country?
SELECT * FROM allsession_analytics_combined
WHERE v2productcategory = 'N/A';

-- Product categories account for most sales by country
SELECT country, v2productcategory
	, SUM(units_sold) AS units_sold
FROM allsession_analytics_combined
GROUP BY 
	v2productcategory
	, country
ORDER BY SUM(units_sold) DESC
;

-- Product categories account for most sales by city
 SELECT city, v2productcategory
	, SUM(units_sold) AS units_sold
FROM allsession_analytics_combined
GROUP BY 
	v2productcategory
	, city
ORDER BY SUM(units_sold) DESC
;

-- Question 4: What is the top-selling product from each city/country? 
-- Can we find any pattern worthy of noting in the products sold?

-- Sales by country as units sold
WITH cte_unitssoldbycountry AS (
SELECT country, v2productname
	, SUM(units_sold) AS total_units_sold 
FROM allsession_analytics_combined
GROUP BY v2productname, country
ORDER BY country, SUM(units_sold) DESC
)
SELECT v2productname
	, country
	, MAX(total_units_sold) OVER(partition by country) AS max_units_sold
FROM cte_unitssoldbycountry
;

-- Sales by city as units sold
WITH cte_unitssoldbycity AS (
SELECT city, v2productname
	, SUM(units_sold) AS total_units_sold 
FROM allsession_analytics_combined
GROUP BY v2productname, city
ORDER BY city, SUM(units_sold) DESC
)
SELECT v2productname
	, city
	, MAX(total_units_sold) OVER(partition by city) AS max_units_sold
FROM cte_unitssoldbycity
;

-- Sales by city as revenue from units sold
WITH cte_totalsalesvalue AS (
SELECT city, v2productname
	, SUM(units_sold*unit_price)::numeric(10,2) AS total_sales_value
FROM allsession_analytics_combined
GROUP BY v2productname, city
ORDER BY city, SUM(units_sold*unit_price)::numeric(10,2) DESC
)
SELECT v2productname
	, city
	, MAX(total_sales_value) OVER(partition by city) AS max_units_sold
FROM cte_totalsalesvalue
;

-- Sales by country as revenue from units sold
WITH cte_totalsalesvalue AS (
SELECT country, v2productname
	, SUM(units_sold*unit_price)::numeric(10,2) AS total_sales_value
FROM allsession_analytics_combined
GROUP BY v2productname, country
ORDER BY country, SUM(units_sold*unit_price)::numeric(10,2) DESC
)
SELECT v2productname
	, country
	, MAX(total_sales_value) OVER(partition by country) AS max_units_sold
FROM cte_totalsalesvalue
;

-- Question 5: Can we summarize the impact of revenue generated from each city/country?
SELECT * FROM allsession_analytics_combined
ORDER BY totaltransactionrevenue DESC

-- Transaction revenue by country
SELECT country, SUM(DISTINCT totaltransactionrevenue) AS totalrevenue
FROM allsession_analytics_combined
GROUP BY country
ORDER BY SUM(DISTINCT totaltransactionrevenue) DESC

-- Transaction revenue by city
SELECT city, SUM(DISTINCT totaltransactionrevenue)::float4 AS totalrevenue
FROM allsession_analytics_combined
GROUP BY city
ORDER BY SUM(DISTINCT totaltransactionrevenue) DESC


