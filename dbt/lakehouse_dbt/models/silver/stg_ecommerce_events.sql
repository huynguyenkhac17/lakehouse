-- Silver Layer: Cleaned E-commerce Events
-- Sử dụng dbt để transform từ Bronze

{{ config(
    materialized='table',
    file_format='iceberg',
    partition_by=['event_date']
) }}

WITH bronze_data AS (
    SELECT * FROM lakehouse.bronze.ecommerce_events
),

cleaned AS (
    SELECT
        -- Parse timestamp
        to_timestamp(event_time, "yyyy-MM-dd HH:mm:ss 'UTC'") AS event_timestamp,
        to_date(to_timestamp(event_time, "yyyy-MM-dd HH:mm:ss 'UTC'")) AS event_date,
        hour(to_timestamp(event_time, "yyyy-MM-dd HH:mm:ss 'UTC'")) AS event_hour,

        -- Clean event type
        lower(event_type) AS event_type,

        -- Product info
        product_id,
        category_id,
        COALESCE(category_code, 'uncategorized') AS category_code,
        COALESCE(brand, 'unknown') AS brand,
        CAST(price AS DECIMAL(10,2)) AS price,

        -- User info
        user_id,
        user_session,

        -- Metadata
        current_timestamp() AS _processed_at

    FROM bronze_data
    WHERE event_time IS NOT NULL
)

SELECT * FROM cleaned
