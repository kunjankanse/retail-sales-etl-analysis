SELECT * FROM df_orders

--find top 10 highest revenue generating products
SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC

--find top 5 highest selling products in each region
WITH cte AS(
SELECT region, product_id, SUM(sale_price) as sales
FROM df_orders
GROUP BY region, product_id)
SELECT * FROM
(SELECT *, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
FROM cte) A
WHERE rn <= 5;

--find month over month growth comparison for 2022 and 2023 sales e.g.: Jan 2022 vs Jan 2023
WITH cte AS(
select YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, SUM(sale_price) AS sales
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
	SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
	SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

--for each category which month had highest sales
WITH cte AS(
SELECT category, FORMAT(order_date, 'yyyyMM') AS order_year_month, SUM(sale_price) AS sales
FROM df_orders
GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT * FROM
(SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
FROM cte) a
WHERE rn = 1;

--which sub category had highest growth by profit in 2023 compared to 2022
WITH cte AS(
select sub_category, YEAR(order_date) AS order_year, SUM(sale_price) AS sales
FROM df_orders
GROUP BY sub_category, YEAR(order_date)
), cte2 AS(
SELECT sub_category,
	SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
	SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category
)
SELECT TOP 1 *, (sales_2023 - sales_2022) * 100 / sales_2022
FROM cte2
ORDER BY (sales_2023 - sales_2022) * 100 / sales_2022 DESC
