-- Each block starts with "-- name: <id>" so analysis.py can run and label it.

-- name: headline_kpis
SELECT
    SUM(total_amount)                       AS total_revenue,
    COUNT(*)                                AS transactions,
    SUM(quantity)                           AS units_sold,
    ROUND(AVG(total_amount), 2)             AS avg_order_value,
    ROUND(AVG(age), 1)                      AS avg_customer_age,
    ROUND(1.0 * SUM(quantity) / COUNT(*), 2) AS avg_units_per_order,
    COUNT(DISTINCT customer_id)             AS unique_customers
FROM retail_sales;

-- name: revenue_by_category
SELECT
    category,
    SUM(total_amount)                                         AS revenue,
    ROUND(100.0 * SUM(total_amount) / (SELECT SUM(total_amount) FROM retail_sales), 1) AS revenue_share_pct,
    SUM(quantity)                                             AS units,
    COUNT(*)                                                  AS orders,
    ROUND(AVG(total_amount), 1)                               AS avg_order_value
FROM retail_sales
GROUP BY category
ORDER BY revenue DESC;

-- name: revenue_by_month
SELECT sale_month, SUM(total_amount) AS revenue, COUNT(*) AS orders
FROM retail_sales
GROUP BY sale_month
ORDER BY sale_month;

-- name: peak_and_lowest_month
WITH m AS (
    SELECT sale_month, SUM(total_amount) AS revenue
    FROM retail_sales
    WHERE sale_month BETWEEN '2023-01' AND '2023-12'
    GROUP BY sale_month
)
SELECT 'peak' AS kind, sale_month, revenue FROM m WHERE revenue = (SELECT MAX(revenue) FROM m)
UNION ALL
SELECT 'lowest', sale_month, revenue FROM m WHERE revenue = (SELECT MIN(revenue) FROM m);

-- name: revenue_by_quarter
SELECT quarter, SUM(total_amount) AS revenue
FROM retail_sales
WHERE quarter LIKE '2023-%'
GROUP BY quarter
ORDER BY quarter;

-- name: revenue_by_gender
SELECT
    gender,
    SUM(total_amount) AS revenue,
    ROUND(100.0 * SUM(total_amount) / (SELECT SUM(total_amount) FROM retail_sales), 1) AS revenue_share_pct,
    COUNT(*) AS orders
FROM retail_sales
GROUP BY gender
ORDER BY revenue DESC;

-- name: revenue_by_age_group
SELECT age_group, SUM(total_amount) AS revenue, COUNT(*) AS orders, ROUND(AVG(total_amount), 1) AS avg_order_value
FROM retail_sales
GROUP BY age_group
ORDER BY age_group;

-- name: category_by_gender
SELECT category, gender, SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY category, gender
ORDER BY category, revenue DESC;

-- name: top_10_customers
SELECT customer_id, SUM(total_amount) AS revenue, COUNT(*) AS orders
FROM retail_sales
GROUP BY customer_id
ORDER BY revenue DESC, customer_id
LIMIT 10;

-- name: price_tier_mix
SELECT
    CASE WHEN unit_price >= 300 THEN 'Premium (300+)'
         WHEN unit_price >= 50  THEN 'Mid (50-299)'
         ELSE 'Low (<50)' END AS price_tier,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY price_tier
ORDER BY revenue DESC;

-- name: running_total_by_month
SELECT sale_month,
       SUM(total_amount) AS revenue,
       SUM(SUM(total_amount)) OVER (ORDER BY sale_month) AS cumulative_revenue
FROM retail_sales
GROUP BY sale_month
ORDER BY sale_month;

-- name: month_over_month_change
WITH m AS (
    SELECT sale_month, SUM(total_amount) AS revenue
    FROM retail_sales
    GROUP BY sale_month
)
SELECT sale_month, revenue,
       LAG(revenue) OVER (ORDER BY sale_month) AS previous_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY sale_month))
             / LAG(revenue) OVER (ORDER BY sale_month), 1) AS change_pct
FROM m
ORDER BY sale_month;
