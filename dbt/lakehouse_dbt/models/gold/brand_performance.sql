-- Gold Layer: Brand Performance
-- Top brands analysis

{{ config(
    materialized='table',
    file_format='iceberg'
) }}

SELECT
    brand,
    COUNT(*) AS total_events,
    COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS views,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS carts,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchases,
    SUM(CASE WHEN event_type = 'purchase' THEN price ELSE 0 END) AS revenue,
    AVG(CASE WHEN event_type = 'purchase' THEN price END) AS avg_order_value,
    COUNT(DISTINCT user_id) AS unique_customers,
    ROUND(
        COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN event_type = 'view' THEN 1 END), 0),
        2
    ) AS conversion_rate,
    current_timestamp() AS _aggregated_at

FROM {{ ref('stg_ecommerce_events') }}
WHERE brand != 'unknown'
GROUP BY brand
ORDER BY revenue DESC
