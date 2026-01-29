-- Gold Layer: Daily Sales Summary
-- Aggregated metrics for dashboards

{{ config(
    materialized='table',
    file_format='iceberg',
    partition_by=['event_date']
) }}

SELECT
    event_date,
    COUNT(*) AS total_events,
    COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS views,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS add_to_cart,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchases,
    SUM(CASE WHEN event_type = 'purchase' THEN price ELSE 0 END) AS revenue,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT user_session) AS unique_sessions,
    ROUND(
        COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN event_type = 'view' THEN 1 END), 0),
        2
    ) AS conversion_rate,
    current_timestamp() AS _aggregated_at

FROM {{ ref('stg_ecommerce_events') }}
GROUP BY event_date
ORDER BY event_date
