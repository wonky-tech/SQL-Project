Answer the following questions and provide the SQL queries used to find the answer.

**NOTE:** Queries below operate on saved table views. Please see the file ``cleaning_data.md`` for the relevant SQL queries to create table views.

**Question 1: Which cities and countries have the highest level of transaction revenues on the site?**

SQL Queries:
```
SELECT country, SUM(totaltransactionrevenue)::float4 as TotalTransactionRevenue
FROM all_sessions_clean
GROUP BY country
ORDER BY SUM(totaltransactionrevenue) DESC
LIMIT 10;

SELECT city, SUM(totaltransactionrevenue)::float4 as TotalTransactionRevenue
FROM all_sessions_clean
GROUP BY city
ORDER BY SUM(totaltransactionrevenue) DESC
LIMIT 10;
```

Answer:
The USA leads total revenue, but only 5 countries post any revenue. The rest are 0 (some converted from NULL).

| Country       | Total Revenue |
| ------------- | ------------- |
| United States | 13154.17      |
| Israel        | 602           |
| Australia     | 358           |
| Canada        | 150.15        |
| Switzerland   | 16.99         |

San Francisco leads as the city revenue, if you exclude entries with the city value ‘N/A’. 

| City          | Total Revenue |
| ------------- | ------------- |
| N/A           | 6092.56       |
| San Francisco | 1564.32       |
| Sunnyvale     | 992.23        |
| Atlanta       | 854.44        |
| Palo Alto     | 608           |
| Tel Aviv-Yafo | 602           |

**Question 2: What is the average number of products ordered from visitors in each city and country?**


SQL Queries:
``` sql 
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
```

Answer:
The USA leads Average Units Sold by country

| Country       | Average Units Sold |
| ------------- | ------------------ |
| United States | 19.24              |
| Czechia       | 15.18              |
| Mexico        | 1.83               |
| Canada        | 1.59               |
| Bulgaria      | 1.50               |
| Germany       | 1.25               |

San Bruno leads Average Units Sold by city, though results are less certain because N/A city is in second place.

| City          | Average Units Sold |
| ------------- | ------------------ |
| San Bruno     | 52.67              |
| N/A           | 26.69              |
| Mountain View | 16.17              |
| San Jose      | 8.57               |
| Salem         | 7.55               |
| New York      | 6.90               |
| Chicago       | 6.19               |



**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**

SQL Queries:
``` sql
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
```

Answer:
The top-selling category is Pet Accessories in the USA. Czechia's top sellers are from the category N/A. Hong Kong is Electronics Accessories. Canada's top-selling category is for YouTube merchandise.

|Country|Product Category|Units Sold|
|---|---|---|
|United States|	Home/Accessories/Pet/| 22665|
|Czechia|	N/A|	167|
|Hong Kong|Home/Electronics/Electronics Accessories/|120|
|Canada|	Home/Shop by Brand/YouTube/| 45|
|Japan|	Home/Shop by Brand/Google/| 28|

The city N/A has the top sales, with Pet Accessories. Excluding N/A (there's a lot of them for cities), Mountain View, New York and San Bruno are the top three cities, respectively.

|City|Product Category|Units Sold|
|---|---|---|
|N/A|	Home/Accessories/Pet/|22656|
|Mountain View|	Home/Accessories/Stickers/|5807|
|New York|	N/A|	1442|
|San Bruno|	Home/Shop by Brand/YouTube/|1397|
|Charlotte|	Home/Bags/|	776|
|Sunnyvale| Home/Office/Notebooks & Journals/|502|

**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**

Top-selling products could be described as the number of units sold or the revenue from the units sold, by city/country. I have tried to answer these separately. There are a lot of tied values for each product, making it difficult to see clear winners per city/country.

SQL Queries for Units Sold:
``` sql
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
```
Answer for Units Sold:

Excerpts illustrate tied top-selling products for city/country.

| Product|Country |Units Sold|
|-|-|-|
|Android Sticker Sheet Ultra Removable|Australia| 2|
|YouTube Men's Vintage Henley|Australia|2|
|22 oz YouTube Bottle Infuser|Australia|2|
|Google Women's Short Sleeve Hero Tee Sky Blue|Australia|2|
|Google Men's Vintage Tank|Australia|2|
|Google Car Clip Phone Holder|Austria|1|
|Google Stylus Pen w/ LED Light|Belarus|2|
|Google 17 oz Double Wall Stainless Steel Insulated Bottle|Belgium|2|
|YouTube Men's Vintage Tank|Bulgaria|3|
|YouTube Leatherette Notebook Combo|Canada|42|
|Google Men's 3/4 Sleeve Raglan Henley Grey|Canada|42|

| Product | City  | Units Sold |
|-|-|-|
|Google Youth Short Sleeve T-shirt Royal Blue|Ahmedabad|2|
|Recycled Mouse Pad|Ann Arbor|74|
|Google Men's Vintage Tank|Ann Arbor|74|
|Yoga Block|Ann Arbor|	74|
|Google Men's Vintage Badge Tee Black|Ann Arbor|74|
|Keyboard DOT Sticker|Ann Arbor|74|
|Google Women's Scoop Neck Tee White|Ann Arbor|74|
|20 oz Stainless Steel Insulated Tumbler|Atlanta|25|
|Google Onesie Green|Atlanta|25|
|Waterproof Backpack|Atlanta|25|
|Google Rucksack|Atlanta|	25|
|Google Alpine Style Backpack|Atlanta|25|
|Android Men's Vintage Henley|Atlanta|25|
|YouTube RFID Journal|Austin|162|
|25L Classic Rucksack|Austin|162|


SQL Queries for total revenue from units sold:
```sql
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
```

Answer for Revenue from Units Sold:






**Question 5: Can we summarize the impact of revenue generated from each city/country?**

SQL Queries:
```sql
-- Transaction revenue by country
SELECT country, SUM(DISTINCT totaltransactionrevenue) 
FROM allsession_analytics_combined
GROUP BY country
ORDER BY SUM(DISTINCT totaltransactionrevenue) DESC

-- Transaction revenue by city
SELECT city, SUM(DISTINCT totaltransactionrevenue)::float4 AS totalrevenue
FROM allsession_analytics_combined
GROUP BY city
ORDER BY SUM(DISTINCT totaltransactionrevenue) DESC
```

Answer:
This answer considers only the first of each revenue value for each city/country. Revenue values in the data appear to be repeated on each line per visit. Considering only the first of each revenue value per visit does not impact countries ranking, but has a small impact on the absolute value per country/city.

Only three countries post revenue -- The USA, Canada and Switzerland -- ordered from top. 

|Country| Total Revenue|
|--------|--------------|
|United States|	3625.76|
|Canada|	82.16|
|Switzerland|	16.99|
|Belgium|	0|
|Bulgaria|	0|

There are 11 cities with non-zero revenue entries. Excluding the N/A as the top revenue value, Sunnyvale is the top revenue generating city.

|City| Total Revenue|
|--------|--------------|
|N/A|	1368.93|
|Sunnyvale|	672.23|
|Seattle|	358|
|San Francisco|	312.68|
|Chicago|	306|
|Mountain View|	159.97|
|Nashville|	157|
|Palo Alto|	151|
|New York|	139.95|
|Toronto|	82.16|
|Zurich|	16.99|
|Dallas|	0|


