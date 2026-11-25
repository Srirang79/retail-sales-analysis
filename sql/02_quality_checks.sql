-- name: row_count
SELECT COUNT(*) AS rows_loaded FROM retail_sales;

-- name: null_or_blank_values
SELECT
    SUM(sale_date = '' OR sale_date IS NULL)   AS missing_date,
    SUM(gender = '' OR gender IS NULL)         AS missing_gender,
    SUM(category = '' OR category IS NULL)     AS missing_category,
    SUM(total_amount IS NULL)                  AS missing_amount
FROM retail_sales;

-- name: duplicate_transaction_ids
SELECT COUNT(*) - COUNT(DISTINCT transaction_id) AS duplicate_ids FROM retail_sales;

-- name: amount_matches_quantity_times_price
SELECT COUNT(*) AS mismatched_rows
FROM retail_sales
WHERE ABS(total_amount - quantity * unit_price) > 0.001;

-- name: date_range_and_age_range
SELECT MIN(sale_date) AS first_sale, MAX(sale_date) AS last_sale,
       MIN(age) AS youngest, MAX(age) AS oldest
FROM retail_sales;
