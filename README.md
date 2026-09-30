# DataCo Supply Chain Delay Analysis

## Overview
Exploratory SQL analysis of ~180K orders from DataCo's supply chain dataset, 
looking at shipping delay patterns by region, shipping mode, and product category.

## Data Source
[DataCo Smart Supply Chain for Big Data Analysis](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) (Kaggle)

Raw CSV is not committed to this repo (see `.gitignore`) — download it from the 
link above and load it into a local PostgreSQL database to reproduce.

## Tools
PostgreSQL, DBeaver

## Findings

### Day 1 — Exploratory Analysis
- Loaded and validated the dataset (~180K rows, 53 columns, 23 distinct order regions)
- Computed average shipping delay (`Days for shipping (real)` − `Days for shipment (scheduled)`) by region
- Central Asia and Central Africa had the highest average delay (~0.64 days); most other regions clustered closer to 0.55–0.6 days

### Day 2 — Window Functions & Trend Analysis
- Ranked average delay by region, shipping mode, and product category using `RANK()`
- Built a month-over-month delay trend using a CTE and `LAG()`
- Delay is roughly flat across the ~3-year period — fluctuates in a narrow band with no clear upward or downward trend

### Day 3 — Data Modeling & Segment Analysis
- Split the flat table into a mini star schema: `dim_customers`, `dim_products`, and `fact_orders`, with primary keys and foreign key constraints enforced between them
- Data quality finding: `dim_products` initially contained duplicate rows per `Product Card Id` (inconsistent category/department values attached to the same product ID) — resolved using `DISTINCT ON` to keep one canonical row per product
- Joined the fact table against both dimensions to analyze average shipping delay by customer segment and by department
- We can see that the data shows Pet Shop products are the most likely to experience delays being over 10% more likely than product categories.
- Built a reusable view, `vw_delay_by_region_mode`, summarizing order count and average delay by region and shipping mode

## How to Reproduce
1. Download the dataset from the Kaggle link above
2. Load `DataCoSupplyChainDataset.csv` into a PostgreSQL database
3. Run the scripts in `/sql` in order (`01_`, `02_`, ...)
