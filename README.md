# Retail Sales Analysis

SQL and Python analysis of 1,000 retail transactions (2023), plus an interactive Streamlit dashboard. It answers: how much did we sell, which categories and customers drive revenue, and when does demand peak.

## Data

Retail Sales Dataset, a public dataset on Kaggle (author: Mohammad Talib): https://www.kaggle.com/datasets/mohammadtalib786/retail-sales-dataset

1,000 rows, one per transaction: `Transaction ID, Date, Customer ID, Gender, Age, Product Category, Quantity, Price per Unit, Total Amount`. Dates run from 1 Jan 2023 to 1 Jan 2024. The file is in `data/retail_sales_dataset.csv`. The analysis code in this repository is original.

## Key findings

| Metric | Value |
| --- | --- |
| Total revenue | $456,000 |
| Transactions | 1,000 |
| Units sold | 2,514 |
| Average order value | $456 |
| Average customer age | 41.4 |

- **Electronics leads on revenue:** $156,905, 34.4% of the total. Clothing is close behind at $155,580 (34.1%) and Beauty has $143,515 (31.5%).
- **Beauty has the highest average order value:** $467, against $459 for Electronics and $443 for Clothing. Clothing wins on volume (351 orders, 894 units).
- **May is the peak month** at $53,150. **September is the low** at $23,620. October rebounds to $46,580.
- **Q4 is the strongest quarter:** $126,190, then Q2 at $123,735.
- **Women contribute 51.1% of revenue** ($232,840) and men 48.9%.
- **The 46-55 age group is the biggest spender** at $100,690, followed by 26-35 at $98,480.
- Two orders dated 1 Jan 2024 ($1,530) are in the totals but outside the 2023 monthly and quarterly views.

Full result tables are in [`RESULTS.md`](RESULTS.md).

## How the analysis works

1. `analysis.py` loads the CSV into an in-memory SQLite table and fixes the date format.
2. `sql/01_schema.sql` builds the typed `retail_sales` table and adds `age_group`, `sale_month` and `quarter`.
3. `sql/02_quality_checks.sql` checks row count, blanks, duplicate IDs and that `total_amount = quantity * unit_price` (all clean).
4. `sql/03_analysis.sql` holds the business queries: KPIs, category, month, quarter, gender, age group, top customers, price tiers, running total and month-over-month change with window functions.
5. `test_results.py` asserts the headline numbers above so a code change cannot silently alter them.

The SQL uses the SQLite dialect and standard constructs (CTEs, window functions), so it ports to MySQL or PostgreSQL with small changes to the date functions.

## Run it

```bash
pip install -r requirements.txt
python analysis.py          # prints every result and writes RESULTS.md
python test_results.py      # verifies the headline numbers
streamlit run app.py        # interactive dashboard
```

## Files

| Path | Purpose |
| --- | --- |
| `app.py` | Streamlit dashboard with category, gender and age filters |
| `analysis.py` | Runs the SQL files and writes `RESULTS.md` |
| `sql/` | Schema, quality checks and analysis queries |
| `test_results.py` | Headline-number checks |
| `data/` | Source dataset |
