create database project1

UPDATE sales_cleaned
SET store_id = NULL
WHERE store_id = '-';

SELECT DISTINCT s.store_id
FROM sales_cleaned s
LEFT JOIN stores_cleaned st
    ON s.store_id = st.store_id
WHERE s.store_id IS NOT NULL
  AND st.store_id IS NULL;


 SELECT 
    name AS fk_name
FROM sys.foreign_keys;


-- the total revenue generated in the last 12 months --
SELECT ROUND(SUM(total_amount),2) AS 'TOTAL REVENUE GENERATED IN LAST 12 MONTHS' FROM sales_cleaned
WHERE order_date >= DATEADD(MONTH,-12,(SELECT MAX(order_date) from sales_cleaned))


-- the top 5 best-selling products by quantity --
SELECT TOP 5
    p.product_name,
    SUM(s.quantity) AS total_quantity_sold
FROM sales_cleaned s
JOIN products_cleaned p
    ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;


-- customers based on each region --
SELECT
    region,
    COUNT(*) AS customer_count
FROM customers_cleaned
GROUP BY region
ORDER BY customer_count DESC;



-- the  store which has  highest profit in the past year --
SELECT TOP 1
    st.store_name,
    SUM(s.profit) AS total_profit
FROM sales_cleaned s
JOIN stores_cleaned st
    ON s.store_id = st.store_id
WHERE s.order_date >= DATEADD(YEAR, -1, (SELECT MAX(order_date) from sales_cleaned))
GROUP BY st.store_name
ORDER BY total_profit DESC;




-- return rate by product category --
SELECT
    p.category,
    COUNT(r.return_id) * 1.0 / COUNT(s.order_id) AS return_rate
FROM sales_cleaned s
JOIN products_cleaned p
    ON s.product_id = p.product_id
LEFT JOIN returns_cleaned r
    ON s.order_id = r.order_id
GROUP BY p.category;





-- average revenue per customer by age group --
SELECT
    c.age_group,
    AVG(s.total_amount) AS avg_revenue_per_customer
FROM sales_cleaned s
JOIN customers_cleaned c
    ON s.customer_id = c.customer_id
GROUP BY c.age_group
ORDER BY avg_revenue_per_customer DESC;



-- Which sales channel (Online vs In-Store) is more profitable on average? --
SELECT
    sales_channel,
    AVG(profit) AS avg_profit
FROM sales_cleaned
GROUP BY sales_channel
ORDER BY avg_profit DESC;



-- monthly profit change over the last 2 years by region --
SELECT
    st.region,
    FORMAT(s.order_date, 'yyyy-MM') AS month,
    SUM(s.profit) AS total_profit
FROM sales_cleaned s
JOIN stores_cleaned st
    ON s.store_id = st.store_id
WHERE s.order_date >= DATEADD(YEAR, -2, (SELECT MAX(order_date) from sales_cleaned))
GROUP BY st.region, FORMAT(s.order_date, 'yyyy-MM')
ORDER BY month, st.region;



-- top 3 products with the highest return rate in each category --
WITH return_stats AS (
    SELECT
        p.category,
        p.product_name,
        COUNT(r.return_id) * 1.0 / COUNT(s.order_id) AS return_rate
    FROM sales_cleaned s
    JOIN products_cleaned p
        ON s.product_id = p.product_id
    LEFT JOIN returns_cleaned r
        ON s.order_id = r.order_id
    GROUP BY p.category, p.product_name
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY return_rate DESC) AS rn
    FROM return_stats
) t
WHERE rn <= 3;





--  Which 5 customers have contributed the most to total profit, and what is their tenure with the company? --

SELECT TOP 5
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.profit) AS total_profit,
    DATEDIFF(YEAR, c.signup_date, (SELECT MAX(order_date) from sales_cleaned)) AS tenure_years
FROM sales_cleaned s
JOIN customers_cleaned c
    ON s.customer_id = c.customer_id
GROUP BY 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.signup_date
ORDER BY total_profit DESC;


