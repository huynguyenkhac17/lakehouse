-- Gold Layer: Hourly Traffic Pattern
-- Traffic analysis by hour

{{ config(
    materialized='table',
    file_format='iceberg'
) }}

SELECT
    event_hour,
    COUNT(*) AS total_events,
    COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS views,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS carts,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchases,
    SUM(CASE WHEN event_type = 'purchase' THEN price ELSE 0 END) AS revenue,
    current_timestamp() AS _aggregated_at

FROM {{ ref('stg_ecommerce_events') }}
GROUP BY event_hour
ORDER BY event_hour
