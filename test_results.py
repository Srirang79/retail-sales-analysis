"""Checks the headline findings. Run: python test_results.py"""
from analysis import run_all

r = run_all()
k = r["headline_kpis"].iloc[0]
assert k.total_revenue == 456000 and k.transactions == 1000 and k.units_sold == 2514 and k.avg_order_value == 456
cat = r["revenue_by_category"].set_index("category")
assert cat.index[0] == "Electronics" and cat.loc["Electronics", "revenue"] == 156905
assert cat.loc["Electronics", "revenue_share_pct"] == 34.4
assert cat["avg_order_value"].idxmax() == "Beauty"
peak = r["peak_and_lowest_month"].set_index("kind")
assert peak.loc["peak", "sale_month"] == "2023-05" and peak.loc["peak", "revenue"] == 53150
assert peak.loc["lowest", "sale_month"] == "2023-09" and peak.loc["lowest", "revenue"] == 23620
q = r["revenue_by_quarter"].set_index("quarter")["revenue"]
assert q["2023-Q4"] == 126190
age = r["revenue_by_age_group"].set_index("age_group")["revenue"]
assert age.idxmax() == "46-55" and age["46-55"] == 100690
g = r["revenue_by_gender"].set_index("gender")["revenue_share_pct"]
assert g["Female"] == 51.1
assert all(v.iloc[0, 0] == 0 for n, v in r.items() if n in ("duplicate_transaction_ids", "amount_matches_quantity_times_price"))
print("all headline checks passed")
