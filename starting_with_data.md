**Note:** Some results below rely on table views. Please see the file cleaning_data.md for an explanation of the table views created.

**Question 1:** How many non-bouncing visitors are there and how many of them buy something?
SQL Queries:
``` sql
-- The total number of unique visitors is 148642
SELECT DISTINCT visitid
FROM analytics;

-- The number of unique, non-bouncing visitors is 100205
SELECT DISTINCT visitid
FROM analytics
WHERE bounces IS NULL;

-- The number of unique, non-bouncing buyers is 20290
SELECT DISTINCT visitid
FROM analytics
WHERE bounces IS NULL AND units_sold IS NOT NULL;
```
Answer: 
Using traffic data in the analytics table, there were 148642 total unique visits, of which 100205 did not bounce from the site. Of non-bouncing unique visits, 20290 bought something. As each stage acts like a filter in a funnel, we would expect values to decrease from one stage to the next. 


**Question 2:**  Which channelgrouping is the most lucrative source of traffic?

SQL Queries:
``` sql
SELECT channelgrouping , 	SUM(totaltransactionrevenue)::float4
FROM all_sessions_clean
WHERE totaltransactionrevenue IS NOT NULL
GROUP BY channelgrouping;
```
Answer:

The "all sessions clean" table reveals that visitors referred from another site is the group that constitutes the most sales revenue. 

|Referring Channel | Total Transaction Revenue|
|--|--|
|Referral|	6018.68|
|Direct|	4704.19|
|Organic Search|	3163.67 |
|Paid Search|	394.77|
|Affiliates|	0|
|Display|	0|
|(Other)|	0|

**Question 3:** What are the SKU, name and category of the top five selling products?

SQL Queries:
```sql
WITH cte_sales AS (
SELECT 
	DISTINCT sales.productsku
	, sales.total_ordered
	, v2productname
	, v2productcategory
FROM sales_by_sku sales
LEFT JOIN allsession_analytics_combined USING (productsku)
)
SELECT DISTINCT v2productcategory
	, v2productname
	, productsku
	, total_ordered
FROM cte_sales
ORDER BY total_ordered DESC;
```

Answer:
	
|Product Category| Product Name | Product SKU|Total Ordered
|--|--|--|--|
|N/A|N/A|GGOEGOAQ012899|	456
|Home/Drinkware/Water Bottles and Tumblers/|Google 17oz Stainless Steel Sport Bottle|GGOEGDHC074099|	334
|Home/Shop by Brand/Google/|Google 17oz Stainless Steel Sport Bottle|GGOEGDHC074099|	334
|N/A|N/A|GGOEGOCB017499|	319
|N/A|N/A|GGOEGOCC077999|	290
|Home/Drinkware/|Foam Can and Bottle Cooler|GGOEGFYQ016599|	253

This answer highlights numerous problems with the data. Many names and categories are not assigned to the Product SKU. Some SKUs have different categories applied. I'm not sure how to address these issues in the time available.


Question 4: 

SQL Queries:

Answer:



Question 5: 

SQL Queries:

Answer:
