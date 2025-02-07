--- Task 1
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

--- Task 2

SELECT animal,
	repeat_purchase,
	ROUND(AVG(sales::NUMERIC),0) AS avg_sales,
	ROUND(MIN(sales::NUMERIC),0) as min_sales,
	ROUND(MAX(sales::NUMERIC),0) as max_sales
FROM pet_supplies
GROUP BY
	animal, repeat_purchase;

--- Task 3
SELECT 
product_id, 
ROUND(CAST(sales AS numeric),2) AS sales, 
rating

FROM pet_supplies
WHERE animal IN ('Cat', 'Dog') AND repeat_purchase::numeric = 1
ORDER BY sales DESC;