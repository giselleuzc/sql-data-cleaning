![Pet Supplies Image](pet_supplies_picture.png)
# sql-data-cleaning-pet_supplies
Data cleaning of a pet supplies dataset. Used SQL to complete the project.

# Context
PetMind is a retailer of products for pets. They are based in the United States.
PetMind sells products that are a mix of luxury items and everyday items. Luxury items include toys. Everyday items include food.
The company wants to increase sales by selling more products for some animals repeatedly.
They have been testing this approach for the last year.
They now want a report on how repeat purchases impact sales.

# Data
The data is available in the file pet_supplies.csv.

Here are the first 30 observations of the data.
|product_id|category |animal|size  |price   |sales  |rating|repeat_purchase|
|----------|---------|------|------|--------|-------|------|---------------|
|1         |Food     |Bird  |large |51.1    |1860.62|7     |1              |
|2         |Housing  |Bird  |MEDIUM|35.98   |963.6  |6     |0              |
|3         |Food     |Dog   |medium|31.23   |898.3  |5     |1              |
|4         |Medicine |Cat   |small |24.95   |982.15 |6     |1              |
|5         |Housing  |Cat   |Small |26.18   |832.63 |7     |1              |
|6         |Housing  |Dog   |Small |30.77   |874.58 |7     |0              |
|7         |Housing  |Dog   |Small |31.04   |875.07 |5     |0              |
|8         |Toys     |Cat   |medium|28.9    |1074.31|4     |0              |
|9         |Equipment|Fish  |MEDIUM|17.82   |503.67 |5     |0              |
|10        |Medicine |Dog   |medium|24.93   |838.88 |8     |0              |
|11        |Food     |Dog   |Large |40.87   |1457.22|7     |1              |
|12        |Medicine |Bird  |MEDIUM|34.96   |1204.6 |5     |1              |
|13        |Food     |Dog   |MEDIUM|31.07   |889.73 |4     |0              |
|14        |Food     |Dog   |large |40.8    |1450.5 |6     |1              |
|15        |Accessory|Bird  |medium|33.13   |859.29 |4     |1              |
|16        |Accessory|Bird  |large |43.09   |1418.72|1     |1              |
|17        |Equipment|Cat   |small |28.29   |1040.51|5     |1              |
|18        |Toys     |Bird  |medium|43.91   |1521.51|3     |1              |
|19        |Toys     |Cat   |Small |33.87   |1333.9 |6     |0              |
|20        |Toys     |Dog   |large |44      |1792.63|7     |1              |
|21        |Food     |Fish  |medium|unlisted|542.06 |null  |0              |
|22        |Food     |Dog   |large |41      |1456.58|3     |0              |
|23        |-        |Bird  |MEDIUM|32.98   |859.94 |3     |0              |
|24        |Equipment|Cat   |medium|22.99   |790.26 |4     |0              |
|25        |Toys     |Dog   |Small |38.99   |1410.66|3     |0              |
|26        |Housing  |Bird  |large |45.83   |1551.24|4     |1              |
|27        |Equipment|Cat   |Small |28.24   |1046   |4     |0              |
|28        |Equipment|Cat   |small |28.19   |1036.72|5     |1              |
|29        |Equipment|Cat   |Small |27.79   |1031.11|7     |1              |
|30        |Toys     |Dog   |Small |38.86   |1405.4 |5     |1              |

The dataset contains the sales records in the stores last year.

| ColumnName     | Criteria    |
| -------------  |-------------|
| **product_id**    | Nominal. The unique identifier of the product. Missing values are not possible due to the database structure. |
| **category**       | Nominal. The category of the product, one of 6 values (Housing, Food, Toys, Equipment, Medicine, Accessory). Missing values should be replaced with “Unknown”.   |
| **animal**       | Nominal. The type of animal the product is for. One of Dog, Cat, Fish, Bird. Missing values should be replaced with “Unknown”. |
| **size**         | Ordinal. The size of animal the product is for. Small, Medium, Large. Missing values should be replaced with “Unknown”.|
| **price**         | Continuous. The price the product is sold at. Can be any positive value, round to 2 decimal places. Missing values should be replaced with the overall median price.|
| **sales**         | Continuous. The value of all sales of the product in the last year. This can be any positive value, rounded to 2 decimal places. Missing values should be replaced with the overall median sales.|
| **rating**         | Discrete. Customer rating of the product from 1 to 10. Missing values should be replaced with 0.|
| **repeat_purchase**| Nominal. Whether customers repeatedly buy the product (1) or not (0). Missing values should be removed. |

# Task 1
From taking a quick look at the data, you are pretty certain it isn't quite as it should be. You need to make sure all of the data is clean before you start your analysis. The table below shows what the data should look like.
Write a query to return a table that matches the description provided.
Do not update the original table.
## Code
```sql
SELECT 
    product_id,
	COALESCE(NULLIF(REPLACE(category, '-', 'Unknown'), ''), 'Unknown') AS category,
	COALESCE(animal, 'Unknown') AS animal,
	CASE
		WHEN size IS NULL THEN 'Unknown'
		WHEN LOWER(size) LIKE 's%' THEN 'Small'
		WHEN LOWER(size) LIKE 'm%' THEN 'Medium'
		WHEN LOWER(size) LIKE 'l%' THEN 'Large'
		WHEN UPPER(size) LIKE 'SMALL' THEN 'Small'
		WHEN UPPER(size) LIKE 'MEDIUM' THEN 'Medium'
		WHEN UPPER(size) LIKE 'LARGE' THEN 'Large'
		ELSE size END AS size,
	CASE
		WHEN price ILIKE 'unlisted' THEN 0
		ELSE ROUND(price::numeric,2) END AS price,
	COALESCE(ROUND(sales::numeric, 2), (
            SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sales::numeric)
            FROM pet_supplies
        )) AS sales,
	CASE
	WHEN rating ILIKE 'null' THEN 0 
	WHEN rating::integer BETWEEN 1 AND 10 THEN rating::integer
	ELSE 0
	END AS rating,
	repeat_purchase
FROM pet_supplies
WHERE repeat_purchase IS NOT NULL;
```
### Result (first 30 rows)
|product_id|category |animal|size  |price   |sales  |rating|repeat_purchase|
|----------|---------|------|------|--------|-------|------|---------------|
|1         |Food     |Bird  |Large |51.10   |1860.62|7     |1              |
|2         |Housing  |Bird  |Medium|35.98   |963.6  |6     |0              |
|3         |Food     |Dog   |Medium|31.23   |898.3  |5     |1              |
|4         |Medicine |Cat   |Small |24.95   |982.15 |6     |1              |
|5         |Housing  |Cat   |Small |26.18   |832.63 |7     |1              |
|6         |Housing  |Dog   |Small |30.77   |874.58 |7     |0              |
|7         |Housing  |Dog   |Small |31.04   |875.07 |5     |0              |
|8         |Toys     |Cat   |Medium|28.90   |1074.31|4     |0              |
|9         |Equipment|Fish  |Medium|17.82   |503.67 |5     |0              |
|10        |Medicine |Dog   |Medium|24.93   |838.88 |8     |0              |
|11        |Food     |Dog   |Large |40.87   |1457.22|7     |1              |
|12        |Medicine |Bird  |Medium|34.96   |1204.6 |5     |1              |
|13        |Food     |Dog   |Medium|31.07   |889.73 |4     |0              |
|14        |Food     |Dog   |Large |40.80   |1450.5 |6     |1              |
|15        |Accessory|Bird  |Medium|33.13   |859.29 |4     |1              |
|16        |Accessory|Bird  |Large |43.09   |1418.72|1     |1              |
|17        |Equipment|Cat   |Small |28.29   |1040.51|5     |1              |
|18        |Toys     |Bird  |Medium|43.91   |1521.51|3     |1              |
|19        |Toys     |Cat   |Small |33.87   |1333.9 |6     |0              |
|20        |Toys     |Dog   |Large |44.00   |1792.63|7     |1              |
|21        |Food     |Fish  |Medium|0       |542.06 |0     |0              |
|22        |Food     |Dog   |Large |41.00   |1456.58|3     |0              |
|23        |Unknown  |Bird  |Medium|32.98   |859.94 |3     |0              |
|24        |Equipment|Cat   |Medium|22.99   |790.26 |4     |0              |
|25        |Toys     |Dog   |Small |38.99   |1410.66|3     |0              |
|26        |Housing  |Bird  |Large |45.83   |1551.24|4     |1              |
|27        |Equipment|Cat   |Small |28.24   |1046   |4     |0              |
|28        |Equipment|Cat   |Small |28.19   |1036.72|5     |1              |
|29        |Equipment|Cat   |Small |27.79   |1031.11|7     |1              |
|30        |Toys     |Dog   |Small |38.86   |1405.4 |5     |1              |

# Task 2
You want to show whether sales are higher for repeat purchases for different animals. You also want to give a range for the sales.
Write a query to return the animal, repeat_purchase indicator and the avg_sales, along with the min_sales and max_sales. All values should be rounded to whole numbers.
You should use the original pet_supplies data for this task.
## Code
```sql
SELECT animal,
	repeat_purchase,
	ROUND(AVG(sales::NUMERIC),0) AS avg_sales,
	ROUND(MIN(sales::NUMERIC),0) as min_sales,
	ROUND(MAX(sales::NUMERIC),0) as max_sales
FROM pet_supplies
GROUP BY
	animal, repeat_purchase
```
### Result
|animal|repeat_purchase|avg_sales|min_sales|max_sales|
|------|---------------|---------|---------|---------|
|Fish  |0              |705      |288      |1307     |
|Dog   |0              |1084     |574      |1795     |
|Cat   |0              |1035     |512      |1730     |
|Cat   |1              |998      |512      |1724     |
|Bird  |0              |1380     |858      |2255     |
|Bird  |1              |1408     |853      |2256     |
|Dog   |1              |1038     |574      |1797     |
|Fish  |1              |693      |287      |1301     |

# Task 3
The management team want to focus on efforts in the next year on the most popular pets - cats and dogs - for products that are bought repeatedly.
Write a query to return the product_id, sales and rating for the relevant products.
You should use the original pet_supplies data for this task.
## Code
```sql
SELECT 
product_id, 
ROUND(CAST(sales AS numeric),2) AS sales, 
rating

FROM pet_supplies
WHERE animal IN ('Cat', 'Dog') AND repeat_purchase::numeric = 1
ORDER BY
	sales DESC;
```
### Results (First 20 rows)
|product_id|sales    |rating|
|----------|---------|------|
|518       |1797.02  |7     |
|280       |1795.77  |5     |
|728       |1793.71  |6     |
|20        |1792.63  |7     |
|946       |1788.28  |8     |
|863       |1724.15  |7     |
|1383      |1723.87  |8     |
|272       |1470.65  |6     |
|561       |1469.55  |5     |
|285       |1467.21  |4     |
|752       |1466.78  |6     |
|332       |1466.30  |6     |
|152       |1464.80  |4     |
|1061      |1463.58  |7     |
|88        |1463.29  |4     |
|370       |1462.67  |null  |
|1234      |1461.92  |null  |
|495       |1460.29  |6     |
|987       |1460.01  |2     |
|1135      |1458.21  |6     |
|1143      |1457.65  |5     |
