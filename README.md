# Final-Project-Transforming-and-Analyzing-Data-with-SQL

## Project/Goals
The project is to clean and analyze a messy data set that lacks documentation or context. The goal is to demonstrate proficiency with SQL but checking the quality of the data, cleaning data for further analysis, and analyzing the data to extract some insights from it.

## Process
1. Load five CSV files into Postgresql database tables. See file `QA.md`
2. Get a general sense of the data, what goes where, and what aspects of the data may need rectification. See file `QA.md`
3. Clean data and combine most important columns into a single table to facilitate analysis. See file `cleaning_data.md`
4. Answer set questions about the data. See file `starting_with_questions.md`
5. Develop additional questions about the data, and provide answers with appropriate queries. See file `starting_with_data.md`
6. Present general method and results, with commentary. (This file)

There is also a `/src` folder containing files of SQL queries used in the cleaning and analysis. It is included for completeness, but is intended for my own reference.

## Results
Full details of analysis appear in `starting_with_questions.md` and `starting_with_data.md`
From the defined questions of `starting_with_questions.md`:
1. The highest level of transaction revenue is in the USA. City revenue is uncertain due to the high number of missing city values; The N/A city value comes first, followed by San Francisco.
2. The average number of products ordered is highest in the USA, with San Bruno leading the cities.
3. The USA leads product category sales. The biggest category of sales is Pet Accessories. For cities, again N/A tops category sales, also with Pet Accessories. Missing category and city values make this result especially uncertain.
4. The top selling product for city/country could be described as 'units sold' or total revenue from unit sales. The answer in `starting_with_questions.md` addresses both.
5. The impact of revenue generated shows that only three countries -- The USA, Canada and Switzerland -- post any revenue. The US leads this list by a large margin.

## Challenges 
The dataset comes with no documentation or context, making it harder to figure out what it is describing. For many columns, it is unclear what the numbers mean, whether they are in a sensible range or at all correct. The schema is not very well set up, so that there are columns duplicated across different tables. The `all_sessions.md` table in particular appears to be an amalgam of separate tables.

## Future Goals
I'd prefer to find some documentation on the dataset to guide its interpretation. It feels like a lot of the analysis is guesswork, for instance, it is not obvious what some columns or entries are meant to represent. 

It would be helpful to come up with better strategies for filling in gaps in the data. In particular, numerous city values are N/A. Also, many products have no category and some are listed with different categories.

A more sensible, tidier schema would also improve analysis. Remove duplicated columns and 'everything' tables that include more information than is necessary. For instance, tables could be separated to focus on a single thing, eg product catalog, sales, website activity. As it is, these are unhelpfully muddled together.
