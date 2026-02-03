-- CLICKHOUSE OPTIMIZED TABLES FOR LAKEHOUSE
-- Run after Spark has written Gold layer data to MinIO

-- Create database
CREATE DATABASE IF NOT EXISTS lakehouse;

--  S3 Engine (Zero-Copy, reads directly from MinIO)
-- Use this for ad-hoc queries on fresh data

CREATE OR REPLACE TABLE lakehouse.s3_daily_sales_summary
ENGINE = S3('http://minio:9000/lakehouse/gold/daily_sales_summary/data/*.parquet',
             'admin', 'password', 'Parquet');

CREATE OR REPLACE TABLE lakehouse.s3_brand_performance
ENGINE = S3('http://minio:9000/lakehouse/gold/brand_performance/data/*.parquet',
             'admin', 'password', 'Parquet');

CREATE OR REPLACE TABLE lakehouse.s3_hourly_traffic
ENGINE = S3('http://minio:9000/lakehouse/gold/hourly_traffic/data/*.parquet',
             'admin', 'password', 'Parquet');

CREATE OR REPLACE TABLE lakehouse.s3_daily_sales_by_category
ENGINE = S3('http://minio:9000/lakehouse/gold/daily_sales_by_category/data/*.parquet',
             'admin', 'password', 'Parquet');

--  MergeTree Engine (Optimized with Primary Key & Indices)
-- Use this high-performance dashboard queries

-- Daily Sales Summary - Optimized
CREATE TABLE IF NOT EXISTS lakehouse.daily_sales_summary
(
    event_date Date,
    total_events UInt64,
    views UInt64,
    add_to_cart UInt64,
    purchases UInt64,
    revenue Decimal(12,2),
    unique_users UInt64,
    conversion_rate Decimal(5,2),
    _aggregated_at DateTime DEFAULT now(),

    -- Data Skipping Index for fast filtering
    INDEX idx_revenue revenue TYPE minmax GRANULARITY 1,
    INDEX idx_purchases purchases TYPE minmax GRANULARITY 1
)
ENGINE = MergeTree()
PRIMARY KEY (event_date)
ORDER BY (event_date)
SETTINGS index_granularity = 8192;

-- Brand Performance - Optimized
CREATE TABLE IF NOT EXISTS lakehouse.brand_performance
(
    brand String,
    total_events UInt64,
    views UInt64,
    purchases UInt64,
    revenue Decimal(12,2),
    avg_order_value Decimal(10,2),
    unique_customers UInt64,
    conversion_rate Decimal(5,2),
    _aggregated_at DateTime DEFAULT now(),

    -- Data Skipping Indices
    INDEX idx_revenue revenue TYPE minmax GRANULARITY 1,
    INDEX idx_brand brand TYPE bloom_filter(0.01) GRANULARITY 1
)
ENGINE = MergeTree()
PRIMARY KEY (brand)
ORDER BY (brand, revenue)
SETTINGS index_granularity = 8192;

-- Hourly Traffic - Optimized
CREATE TABLE IF NOT EXISTS lakehouse.hourly_traffic
(
    event_hour UInt8,
    total_events UInt64,
    views UInt64,
    purchases UInt64,
    revenue Decimal(12,2),
    _aggregated_at DateTime DEFAULT now(),

    -- Data Skipping Index
    INDEX idx_revenue revenue TYPE minmax GRANULARITY 1
)
ENGINE = MergeTree()
PRIMARY KEY (event_hour)
ORDER BY (event_hour)
SETTINGS index_granularity = 8192;

-- Daily Sales by Category - Optimized
CREATE TABLE IF NOT EXISTS lakehouse.daily_sales_by_category
(
    event_date Date,
    category_code String,
    total_events UInt64,
    purchases UInt64,
    revenue Decimal(12,2),
    _aggregated_at DateTime DEFAULT now(),

    -- Data Skipping Indices
    INDEX idx_revenue revenue TYPE minmax GRANULARITY 1,
    INDEX idx_category category_code TYPE bloom_filter(0.01) GRANULARITY 1
)
ENGINE = MergeTree()
PRIMARY KEY (event_date, category_code)
ORDER BY (event_date, category_code, revenue)
PARTITION BY toYYYYMM(event_date)
SETTINGS index_granularity = 8192;

-- LOAD DATA FROM S3 TO OPTIMIZED TABLES
-- Run these after creating tables above

INSERT INTO lakehouse.daily_sales_summary
SELECT * FROM lakehouse.s3_daily_sales_summary;

INSERT INTO lakehouse.brand_performance
SELECT * FROM lakehouse.s3_brand_performance;

INSERT INTO lakehouse.hourly_traffic
SELECT * FROM lakehouse.s3_hourly_traffic;

INSERT INTO lakehouse.daily_sales_by_category
SELECT * FROM lakehouse.s3_daily_sales_by_category;

-- VERIFY DATA & PERFORMANCE

-- Check row counts
SELECT 'daily_sales_summary' as table_name, count() as rows FROM lakehouse.daily_sales_summary
UNION ALL
SELECT 'brand_performance', count() FROM lakehouse.brand_performance
UNION ALL
SELECT 'hourly_traffic', count() FROM lakehouse.hourly_traffic
UNION ALL
SELECT 'daily_sales_by_category', count() FROM lakehouse.daily_sales_by_category;

-- Test optimized query (uses Primary Key)
SELECT * FROM lakehouse.daily_sales_summary
WHERE event_date >= '2019-10-01' AND event_date <= '2019-10-31'
ORDER BY event_date;

-- Test Data Skipping Index (filters by revenue)
SELECT brand, revenue, purchases
FROM lakehouse.brand_performance
WHERE revenue > 1000
ORDER BY revenue DESC
LIMIT 10;

-- SAMPLE ANALYTICS QUERIES FOR SUPERSET

-- KPI 1: Conversion Funnel
SELECT
    sum(views) as total_views,
    sum(add_to_cart) as total_carts,
    sum(purchases) as total_purchases,
    round(sum(add_to_cart) * 100.0 / sum(views), 2) as view_to_cart_rate,
    round(sum(purchases) * 100.0 / sum(add_to_cart), 2) as cart_to_purchase_rate,
    round(sum(purchases) * 100.0 / sum(views), 2) as overall_conversion
FROM lakehouse.daily_sales_summary;

-- KPI 2: Top 10 Brands by Revenue
SELECT
    brand,
    revenue,
    purchases,
    round(revenue / purchases, 2) as avg_order_value,
    conversion_rate
FROM lakehouse.brand_performance
ORDER BY revenue DESC
LIMIT 10;

-- KPI 3: Peak Hours Analysis
SELECT
    event_hour,
    total_events,
    revenue,
    round(revenue / total_events, 4) as revenue_per_event
FROM lakehouse.hourly_traffic
ORDER BY revenue DESC
LIMIT 5;
