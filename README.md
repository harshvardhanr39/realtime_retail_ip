# realtime_retail_ip
# Retail Analytics Data Platform — Project Definition

## 1) Project Brief

This project solves a common retail analytics problem: business teams often have sales, product, inventory, and customer behavior data spread across multiple sources, but they do not have a single trusted platform to monitor performance and make timely decisions. In this project, transactional orders come from Postgres, product attributes come from an API, inventory arrives as daily CSV files, and customer behavior comes from event data. These sources are ingested into a Medallion-style platform, transformed into clean analytics models, and exposed through a dashboard and API. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

The main users of the platform are:
- **Business and operations stakeholders** who need a clear view of revenue, category performance, stock risk, and top-selling products.
- **Inventory and merchandising teams** who need to identify low-stock SKUs and prioritize replenishment.
- **Product or growth teams** who need to understand customer funnel performance from sessions to purchases.
- **Data and platform teams** who need visibility into pipeline runs, freshness, and ingestion health. :contentReference[oaicite:2]{index=2} :contentReference[oaicite:3]{index=3}

The dashboard should support decisions such as:
- whether revenue is increasing or declining over time
- which product categories are driving growth or underperforming
- which SKUs are at risk of stockout and need action
- whether customer conversion is weakening at a specific funnel step
- which products deserve promotion or deeper investigation
- whether the data pipeline is healthy enough to trust the dashboard outputs :contentReference[oaicite:4]{index=4} :contentReference[oaicite:5]{index=5}

---

## 2) Final Dashboard Outputs Recruiters Should See

The final dashboard should clearly showcase the following outputs:

### KPI Cards
High-level summary cards at the top of the dashboard to show core metrics such as total revenue, order count, average order value, conversion rate, and low-stock SKU count. These give recruiters an immediate sense of business impact.

### Revenue Trend
A time-series chart powered by daily revenue data to show how revenue, order volume, and AOV evolve over time. This is one of the main outputs already aligned to `gold.daily_revenue`. 

### Category Performance
A bar chart or pie chart showing revenue by category, units sold, average price, and revenue share. This is already described as the category breakdown chart fed by `gold.category_performance`. 

### Inventory Alerts
A table or alert panel showing SKUs that are low on stock or below reorder point. This should include alert badges and status flags. This output maps to `gold.inventory_health`. 

### Funnel Chart
A conversion funnel visualization showing sessions, product views, add-to-cart events, purchases, and conversion rate by day. This is fed by `gold.customer_funnel`. 

### Top Products
A ranked leaderboard of the top-performing products by revenue and units sold. This comes from `gold.top_products`. 

### Pipeline Health
A monitoring section or separate tab showing pipeline run status, rows ingested, duration, source freshness, and overall system health. The uploaded dashboard already defines endpoints and usage for pipeline monitoring and freshness indicators. 

---

## 3) Final Gold Tables

Below are the final Gold tables that should be fully defined before coding.

### `gold.daily_revenue`

**Business purpose**  
Stores daily sales performance metrics for executive KPI cards and the revenue trend chart. 

**Grain**  
1 row per day. :contentReference[oaicite:13]{index=13}

**Primary key logic**  
`date` must be unique.

**Suggested columns**
- `date`
- `total_revenue`
- `order_count`
- `aov`
- `refund_count`
- `units_sold`
- `net_revenue`
- `last_updated_at`

**Refresh cadence**  
Daily after the main batch pipeline completes.

**Frontend consumers**
- KPI cards
- revenue trend chart
- dashboard header freshness context

---

### `gold.category_performance`

**Business purpose**  
Measures how each product category performs over time, helping users identify growth drivers, weak segments, and category mix. 

**Grain**  
1 row per category per day. :contentReference[oaicite:15]{index=15}

**Primary key logic**  
Composite uniqueness on `date + category`.

**Suggested columns**
- `date`
- `category`
- `revenue`
- `units_sold`
- `avg_price`
- `revenue_share_pct`
- `order_count`
- `last_updated_at`

**Refresh cadence**  
Daily.

**Frontend consumers**
- category performance bar chart
- category share pie chart
- optional category drilldown filters

---

### `gold.inventory_health`

**Business purpose**  
Tracks stock health at SKU level so users can identify low inventory, stockout risk, and replenishment priorities. The uploaded project already positions this table for inventory tables and alerts. 

**Grain**  
1 row per SKU per day. :contentReference[oaicite:17]{index=17}

**Primary key logic**  
Composite uniqueness on `as_of_date + sku_id`.

**Suggested columns**
- `as_of_date`
- `sku_id`
- `product_id`
- `product_name`
- `category`
- `warehouse_id`
- `qty_on_hand`
- `reorder_point`
- `days_of_stock`
- `status_flag`
- `is_low_stock`
- `last_updated_at`

**Refresh cadence**  
Daily, ideally after inventory ingestion and product enrichment.

**Frontend consumers**
- inventory health table
- inventory alerts panel
- low-stock KPI card

---

### `gold.customer_funnel`

**Business purpose**  
Shows how customers progress from visits to purchases and helps teams identify conversion drop-offs. 

**Grain**  
1 row per day. :contentReference[oaicite:19]{index=19}

**Primary key logic**  
`date` must be unique.

**Suggested columns**
- `date`
- `sessions`
- `product_views`
- `add_to_cart`
- `purchases`
- `cvr_pct`
- `add_to_cart_rate`
- `purchase_rate_from_cart`
- `last_updated_at`

**Refresh cadence**  
Daily, with source events ingested hourly and rolled up into the daily Gold table.

**Frontend consumers**
- funnel chart
- conversion KPI card
- growth analysis section

---

### `gold.top_products`

**Business purpose**  
Ranks products by revenue and sales volume to highlight top performers and support merchandising decisions. 

**Grain**  
The uploaded file describes it as 1 row per product. For frontend use, this should typically be generated for a selected reporting period, such as last 30 days. :contentReference[oaicite:21]{index=21}

**Primary key logic**  
For a period-based table or query, uniqueness should be based on `period_start + period_end + product_id`, or it can be exposed as a Gold query over a rolling window.

**Suggested columns**
- `product_id`
- `name`
- `category`
- `total_revenue`
- `units_sold`
- `rank`
- `avg_selling_price`
- `period_start`
- `period_end`
- `last_updated_at`

**Refresh cadence**  
Daily.

**Frontend consumers**
- top products leaderboard
- optional “top movers” or “top sellers” component

---

### `gold.pipeline_health`

**Business purpose**  
Stores operational metrics for each pipeline run so users can monitor ingestion success, duration, row counts, and trustworthiness of the data platform. The uploaded dashboard explicitly uses this for the monitoring tab and freshness views. 

**Grain**  
1 row per pipeline run. :contentReference[oaicite:23]{index=23}

**Primary key logic**  
`run_id` must be unique.

**Suggested columns**
- `run_id`
- `pipeline_name`
- `source`
- `status`
- `rows_ingested`
- `duration_s`
- `ran_at`
- `finished_at`
- `error_message`
- `watermark_before`
- `watermark_after`

**Refresh cadence**  
Updated on every pipeline execution.

**Frontend consumers**
- pipeline runs table
- freshness indicator
- health badge / operational summary

---

## 4) API Endpoints Mapped to Gold Tables

Below is the API design mapped to the final Gold layer.

### Revenue Endpoints

#### `GET /api/v1/revenue/daily`
**Purpose:** Return daily revenue metrics for trend analysis.  
**Gold source:** `gold.daily_revenue`  
**Frontend consumer:** Revenue trend chart, KPI cards

#### `GET /api/v1/revenue/by-category?period=last_30_days`
**Purpose:** Return revenue breakdown by category for a selected period.  
**Gold source:** `gold.category_performance`  
**Frontend consumer:** Category bar chart / pie chart  
This endpoint already exists in the uploaded dashboard specification. :contentReference[oaicite:24]{index=24}

---

### Inventory Endpoints

#### `GET /api/v1/inventory/health`
**Purpose:** Return stock status for all SKUs, with optional filters by status.  
**Gold source:** `gold.inventory_health`  
**Frontend consumer:** Inventory table with badges  
This endpoint is already defined in the uploaded file. :contentReference[oaicite:25]{index=25}

#### `GET /api/v1/inventory/alerts`
**Purpose:** Return only low-stock or reorder-risk SKUs.  
**Gold source:** `gold.inventory_health`  
**Frontend consumer:** Inventory alerts panel / notification badge  
This endpoint is already defined in the uploaded file. :contentReference[oaicite:26]{index=26}

---

### Funnel Endpoints

#### `GET /api/v1/funnel/daily`
**Purpose:** Return daily funnel metrics from sessions through purchases.  
**Gold source:** `gold.customer_funnel`  
**Frontend consumer:** Funnel chart  
This endpoint is already defined in the uploaded file. :contentReference[oaicite:27]{index=27}

---

### Product Endpoints

#### `GET /api/v1/products/top?limit=10&period=last_30_days`
**Purpose:** Return top N products by revenue for the selected period.  
**Gold source:** `gold.top_products` or a Gold-period query over top product metrics  
**Frontend consumer:** Top products leaderboard  
This endpoint is already defined in the uploaded file. :contentReference[oaicite:28]{index=28}

---

### Pipeline Monitoring Endpoints

#### `GET /api/v1/pipeline/runs`
**Purpose:** Return the most recent pipeline runs with status, rows ingested, and duration.  
**Gold source:** `gold.pipeline_health`  
**Frontend consumer:** Pipeline monitoring tab  
This endpoint is already defined in the uploaded file. :contentReference[oaicite:29]{index=29}

#### `GET /api/v1/pipeline/freshness`
**Purpose:** Return freshness by source, based on latest successful pipeline records.  
**Gold source:** `gold.pipeline_health` plus freshness logic/query  
**Frontend consumer:** Freshness indicator in dashboard header  
This endpoint is already defined in the uploaded file. :contentReference[oaicite:30]{index=30}

#### `GET /api/v1/health`
**Purpose:** Return application, database, and pipeline status.  
**Gold source:** operational health query, with latest state derived partly from `gold.pipeline_health`  
**Frontend consumer:** uptime monitor, CI/CD health checks  
This endpoint is already defined in the uploaded file. :contentReference[oaicite:31]{index=31}

---

## 5) Architecture Diagram

You asked to draw the architecture diagram showing source systems, ingestion, Bronze, Silver, Gold, Airflow, FastAPI, and Next.js.

You can place the following in the README as a text diagram first, then replace it later with the final image exported from draw.io or Excalidraw.

```text
┌───────────────────────────────────────────────────────────────────────┐
│                           SOURCE SYSTEMS                             │
│                                                                       │
│  1. Postgres Orders DB        2. Product API                          │
│  3. Daily Inventory CSV       4. Hourly Event JSONL / Clickstream     │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                     INGESTION LAYER (Python + Airflow)                │
│                                                                       │
│  - Source extractors                                                   │
│  - Watermark logic for incrementals                                   │
│  - Metadata logging                                                    │
│  - Basic schema validation                                             │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                        BRONZE LAYER (Raw Storage)                     │
│                                                                       │
│  - Parquet files                                                       │
│  - Partitioned by date / source                                        │
│  - Raw, minimally changed data                                         │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                    SILVER LAYER (dbt on PostgreSQL)                   │
│                                                                       │
│  - Cleaned data                                                        │
│  - Typed columns                                                       │
│  - Deduplicated and standardized                                       │
│  - dbt tests and documentation                                         │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                     GOLD LAYER (Business Marts)                       │
│                                                                       │
│  - daily_revenue                                                       │
│  - category_performance                                                │
│  - inventory_health                                                    │
│  - customer_funnel                                                     │
│  - top_products                                                        │
│  - pipeline_health                                                     │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
┌──────────────────────────────┐   ┌───────────────────────────────────┐
│        FastAPI Backend       │   │      Monitoring / Operations      │
│                              │   │                                   │
│  - Typed REST endpoints      │   │  - Airflow DAG runs              │
│  - Reads from Gold layer     │   │  - Pipeline freshness            │
│  - Health endpoints          │   │  - Failure alerts                │
└───────────────┬──────────────┘   └───────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                     Next.js Dashboard (Frontend)                      │
│                                                                       │
│  - KPI cards                                                          │
│  - Revenue trend                                                      │
│  - Category performance                                               │
│  - Inventory alerts                                                   │
│  - Funnel chart                                                       │
│  - Top products                                                       │
│  - Pipeline health                                                    │
└───────────────────────────────────────────────────────────────────────┘