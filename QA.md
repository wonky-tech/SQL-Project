**What are your risk areas? Identify and describe them.**
Data quality issues:
- Values are missing from the city and country columns in the `all_sessions` table. Missing values do not have a standard placeholder.
- Currency amounts are incorrectly presented in the millions and as integers in the `all_sessions` and `analytics` tables.
- Duplicate product lines are created for unique SKUs because they appear in more than one category in the `all_sessions` table. 
- The same product description is applied to different product SKUs, creating duplicate entries.
- Product SKUs appear to follow different standards. Some are numeric only, others are characters combined with numbers. There is no explanation how these SKUs are generated, if there's a standard method and whether they have any meaning.
- It is unclear what the time value encodes in the `all_sessions` table. It is an integer but does not work as a timestamp. Many entries are 0, a few are single digits and the maximum is 3192410.
- The time on site column contains incorrect NULL and zero values.
- Tables with product and sales figures have different numbers of unique SKUs. Determining why these numbers differ may be worth looking at if time permits.

I've tried to address some of the above in data cleaning with saved table views.

**QA Process:  Describe your QA process and include the SQL queries used to execute it.**

The issues listed above were identified using the process explained below.

### Load five CSV files into PostgreSQL
Each file required the generation of a SQL table. Each table required the identification and assignment of appropriate data types according to the data in the CSV files. Without appropriate documentation or context, some of this was a trial and error process, adjusting column data types to address errors thrown for some columns. I used CSV column headings for the Postgresql table columns

Below is an example of code used to CREATE tables, assign data types and check the final result.
```
DROP TABLE IF EXISTS products;

CREATE TABLE products (
	SKU TEXT,
	name TEXT,
	orderedQuantity INT,
	stockLevel INT,
	restockingLeadTime INT,
	sentimentScore DECIMAL(2,1),
	sentimentMagnitude DECIMAL(2,1)
)
;
SELECT * FROM PRODUCTS;
```
I used a code snippet like this for each Postgresql table. Refer to `ecommerce-erd.png` for a diagram of the resulting tables.

### Getting a general sense of the data, tables and what goes where.
Getting started with this dataset is made more difficult without any documentation or context.

```
SELECT DISTINCT fullvisitorid, * FROM all_sessions; 
-- look for unique entries

SELECT * FROM all_sessions
ORDER BY time;

SELECT * FROM all_sessions
ORDER BY date;
-- check the time and date columns for a sensible range
```
The `all_sessions` table contains website activity data, similar to the `analytics` table described below. However, it has many more columns to describe website visits than the `analytics` table. Many of these columns appear to describe products or sales activity, which makes them seem out of place on a session log. There are 15134 lines containing unique values in the `fullvisitorid` column. 
Columns for `totaltransactionrevenue`, `transactions` `productrefundamount`, `searchkeyword` and `productrevenue`, etc, contain many NULL values, which raises the question: should these be zero'd or excluded? The column `timeonsite` also contains NULL values, which is assumed to be an error, as time on site must be a positive, non-zero value (unless rounded down).
This table contains `country` and `city` columns, presumably for website visitor origin, but possibly for shipping destination. Many lines appear without a city or country and use non-standardized placeholders.
The `productname` and `v2productcategory` columns have duplicate entries created by the same name applied to different SKUs or products in multiple categories.

```
SELECT * FROM analytics; 
-- has units_sold, fullvisitorid

SELECT * FROM analytics
WHERE userid is NOT NULL; --shows no userid is stored

SELECT DISTINCT socialengagementtype, COUNT(*) 
FROM analytics
GROUP BY socialengagementtype
-- shows only 'Not Socially Engaged'

SELECT * FROM analytics
ORDER BY date;
-- Check that dates appear within a reasonable range. All are between May and August, 2018.
```
The table `analytics` gives data from site activity, probably for not logged in users. The `userid` is entirely NULL value. Columns like `fullvisitorid` and `visitid` identify the individual visitors to the site over the pages and actions they complete during a visit. The column `visitid` appears to be a copy of the `visitstarttime` column. The column `visitnumber` appears to coincide with multiple visit start times, making it hard to figure out their purpose. The `channelgrouping` column shows how visitors found the site (ie referred by another site, from a search or directly typing in the URL, etc). The column `socialengagementtype` should probably indicate what social media platforms users use, but gives only 'Not Socially Engaged' as an answer.
Other information about visits is number of pages viewed, time spent on the site, whether a visitor bounced after arrival without looking at other pages, etc. 
With 10-20 lines per `visitid`, this is a very large table, containing 4301,122 lines describing site activity. Of these, 1,739,308 are unique visitors.

```
SELECT * FROM sales_by_sku;
SELECT DISTINCT * FROM sales_by_sku;
```
The table `sales_by_sku` has only two columns: SKU and `total_ordered`. There are 462 unique product SKUs; this table contains more unique SKUs than the`sales_report` table but fewer than the `products` table. I doubt this table will feature much in further analysis as it seems limited. 

```
SELECT DISTINCT * FROM products;
SELECT * FROM products; 
--looking for unique product SKUs
```
The `products` table contains 1092 unique product SKUs, over twice as many as other product-related tables. Is this the full product catalog? Other columns appear to duplicate stock availability and sentiment scores found in the `sales_report` table.

```
SELECT * FROM sales_report; 
-- has total_ordered per product
```
The `sales_report` table contains 454 unique SKUs and product names (but not product categories). Data about these products are mostly concerned with total numbers ordered vs stock levels and other availability metrics. Ratings of sentiment appear to come from customer reviews of the products. A column called `ratio` is meaningless without further description or context but probably relates to product sentiment scores. These ratings appear to be duplicated from `all_sessions`.

```
SELECT * FROM products p
JOIN sales_report sr ON p.sku=sr.productsku
JOIN sales_by_sku sbs ON sbs.productsku=sr.productsku
```
Shows 454 unique SKUs across products and sales tables, raising the question:  what are the other products and why don't all tables have the same number of SKUs?


