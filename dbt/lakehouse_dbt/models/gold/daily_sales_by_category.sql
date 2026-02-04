-- Gold Layer: Daily Sales by Category
-- Aggregated metrics by date and category for trend analysis

{{ config(
    materialized='table',
    file_format='iceberg',
    partition_by=['event_date']
) }}

SELECT
    event_date,
    category_code,
    COUNT(*) AS total_events,
    COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS views,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS add_to_cart,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchases,
    SUM(CASE WHEN event_type = 'purchase' THEN price ELSE 0 END) AS revenue,
    COUNT(DISTINCT user_id) AS unique_users,
    ROUND(
        COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN event_type = 'view' THEN 1 END), 0),
        2
    ) AS conversion_rate,
    current_timestamp() AS _aggregated_at

FROM {{ ref('stg_ecommerce_events') }}
GROUP BY event_date, category_code
ORDER BY event_date, revenue DESC
