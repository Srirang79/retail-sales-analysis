"""Interactive retail sales dashboard (Streamlit)."""
from pathlib import Path

import altair as alt
import pandas as pd
import streamlit as st

st.set_page_config(page_title="Retail Sales Dashboard", page_icon="🛍️", layout="wide")

CSV = Path(__file__).parent / "data" / "retail_sales_dataset.csv"
AGE_BINS = [17, 25, 35, 45, 55, 120]
AGE_LABELS = ["18-25", "26-35", "36-45", "46-55", "56+"]
TEAL = "#2f8f83"


@st.cache_data
def load() -> pd.DataFrame:
    df = pd.read_csv(CSV)
    df.columns = ["transaction_id", "date", "customer_id", "gender", "age", "category", "quantity", "unit_price", "total_amount"]
    df["date"] = pd.to_datetime(df["date"], format="%m/%d/%Y")
    df["month"] = df["date"].dt.to_period("M").astype(str)
    df["quarter"] = df["date"].dt.to_period("Q").astype(str)
    df["age_group"] = pd.cut(df["age"], AGE_BINS, labels=AGE_LABELS).astype(str)
    return df


def bar(data: pd.DataFrame, x: str, y: str, title: str, order=None, highlight: str | None = None) -> alt.Chart:
    color = alt.condition(alt.datum[x] == highlight, alt.value(TEAL), alt.value("#9aa5a3")) if highlight else alt.value(TEAL)
    return (
        alt.Chart(data, title=title)
        .mark_bar()
        .encode(x=alt.X(f"{x}:N", sort=order, title=None), y=alt.Y(f"{y}:Q", title="Revenue ($)"), color=color,
                tooltip=[x, alt.Tooltip(f"{y}:Q", format=",.0f")])
    )


df = load()

st.title("🛍️ Retail Sales Dashboard")
st.caption("1,000 transactions, 1 Jan 2023 to 1 Jan 2024. Use the filters on the left; every number and chart updates.")

with st.sidebar:
    st.header("Filters")
    cats = st.multiselect("Category", sorted(df.category.unique()), default=sorted(df.category.unique()))
    genders = st.multiselect("Gender", sorted(df.gender.unique()), default=sorted(df.gender.unique()))
    ages = st.multiselect("Age group", AGE_LABELS, default=AGE_LABELS)

view = df[df.category.isin(cats) & df.gender.isin(genders) & df.age_group.isin(ages)]
if view.empty:
    st.warning("No transactions match these filters.")
    st.stop()

c1, c2, c3, c4, c5 = st.columns(5)
c1.metric("Total revenue", f"${view.total_amount.sum():,.0f}")
c2.metric("Transactions", f"{len(view):,}")
c3.metric("Units sold", f"{view.quantity.sum():,}")
c4.metric("Avg order value", f"${view.total_amount.mean():,.0f}")
c5.metric("Avg customer age", f"{view.age.mean():.1f}")

monthly = view[view.date < "2024-01-01"].groupby("month", as_index=False).total_amount.sum()
peak = monthly.loc[monthly.total_amount.idxmax(), "month"] if not monthly.empty else None
left, right = st.columns(2)
left.altair_chart(bar(monthly, "month", "total_amount", "Revenue by month, 2023", highlight=peak), width="stretch")
cat = view.groupby("category", as_index=False).total_amount.sum().sort_values("total_amount", ascending=False)
right.altair_chart(bar(cat, "category", "total_amount", "Revenue by category", order=list(cat.category), highlight=cat.iloc[0].category), width="stretch")

a, b, c = st.columns(3)
age = view.groupby("age_group", as_index=False).total_amount.sum()
a.altair_chart(bar(age, "age_group", "total_amount", "Revenue by age group", order=AGE_LABELS, highlight=age.loc[age.total_amount.idxmax(), "age_group"]), width="stretch")
gen = view.groupby("gender", as_index=False).total_amount.sum()
b.altair_chart(bar(gen, "gender", "total_amount", "Revenue by gender", highlight=gen.loc[gen.total_amount.idxmax(), "gender"]), width="stretch")
q = view[view.date < "2024-01-01"].groupby("quarter", as_index=False).total_amount.sum()
c.altair_chart(bar(q, "quarter", "total_amount", "Revenue by quarter, 2023", highlight=q.loc[q.total_amount.idxmax(), "quarter"]), width="stretch")

st.subheader("Category detail")
detail = view.groupby("category").agg(revenue=("total_amount", "sum"), orders=("total_amount", "size"),
                                      units=("quantity", "sum"), avg_order_value=("total_amount", "mean")).round(1)
detail["share_%"] = (100 * detail.revenue / view.total_amount.sum()).round(1)
st.dataframe(detail.sort_values("revenue", ascending=False), width="stretch")
st.caption("Two orders dated 1 Jan 2024 ($1,530) count in the totals but not in the 2023 month and quarter charts.")
