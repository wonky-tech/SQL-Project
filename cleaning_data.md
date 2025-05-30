**What issues will you address by cleaning the data?**

Data cleaning focussed on the `all_sessions` and the `analytics` tables. The tables `all_sessions_clean` and `analytics_clean` were combined into table `allsession_analytics_combined` to facilitate analysis, retaining the columns to be used in later analysis.

Issues identified and corrected in the `all_sessions` table:
- Country and City columns are missing a significant number of named country/city. These were standardized to 'N/A'
- The column `totaltransactionrevenue` is given incorrectly in the millions. This column is reduced by the appropriate amount and stored as a floating point.
- The columns `v2productname` and `v2productcategory` contain what appear to be typos and special characters. These have been corrected, or standardized to 'N/A'

Issues identified and corrected in the `analytics` table:
- The `units_sold` column contains at least one negative value. This is treated as a typo, the negative removed.
- The `unit_price` column is, like revenue above, incorrectly stored as millions. The value is reduced and presented as a float.
- We are focussing on lines with sales, so NULL sales are removed.

In the combined table, the join retains only matching lines, removing lines that  contain null values. However, this may be too aggressive.

**Queries: Below, provide the SQL queries you used to clean your data.**

The queries below address data cleaning in the tables `all_sessions` and analytics. The final query combines the two tables to facilitate data manipulation and analysis.
```sql
-- Create table views of cleaned data for future use.
-- This query cleans the all_sessions table.
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

-- This query cleans the analytics table.
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

-- This query creates allsession_analytics_combined from the two tables.
CREATE OR REPLACE VIEW allsession_analytics_combined AS
	SELECT *
	FROM all_sessions_clean
	-- This join removes null value fullvisitorid lines, which may take out too many valid lines
	JOIN analytics_clean USING(fullvisitorid)
;
```