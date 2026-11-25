-- Retail sales: table definition and cleaning view (SQLite dialect).
-- Every row is one transaction. Raw CSV columns are loaded as-is into retail_raw,
-- then retail_sales is the typed, analysis-ready table.

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transaction_id INTEGER PRIMARY KEY,
    sale_date      TEXT    NOT NULL,   -- ISO yyyy-mm-dd
    customer_id    TEXT    NOT NULL,
    gender         TEXT    NOT NULL,
    age            INTEGER NOT NULL,
    category       TEXT    NOT NULL,
    quantity       INTEGER NOT NULL,
    unit_price     REAL    NOT NULL,
    total_amount   REAL    NOT NULL,
    age_group      TEXT    NOT NULL,
    sale_month     TEXT    NOT NULL,   -- yyyy-mm
    quarter        TEXT    NOT NULL    -- yyyy-Qn
);

INSERT INTO retail_sales
SELECT
    transaction_id,
    sale_date,
    customer_id,
    gender,
    age,
    category,
    quantity,
    unit_price,
    total_amount,
    CASE WHEN age <= 25 THEN '18-25'
         WHEN age <= 35 THEN '26-35'
         WHEN age <= 45 THEN '36-45'
         WHEN age <= 55 THEN '46-55'
         ELSE '56+' END,
    substr(sale_date, 1, 7),
    substr(sale_date, 1, 4) || '-Q' || ((CAST(substr(sale_date, 6, 2) AS INTEGER) + 2) / 3)
FROM retail_staging;
