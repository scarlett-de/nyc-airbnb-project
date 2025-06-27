WITH stg_host AS (
    SELECT * FROM {{ ref('stg_host') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['host_id']) }} AS host_key,
    host_id,
    host_name,
    host_listings_count,
    
    -- Business logic only in dimension table
    CASE
        WHEN host_listings_count > 5 THEN 'Professional'
        WHEN host_listings_count > 1 THEN 'Multi-property'
        ELSE 'Single-property'
    END AS host_type,
    
    CASE
        WHEN host_listings_count >= 10 THEN 'Superhost'
        WHEN host_listings_count >= 5 THEN 'Powerhost'
        ELSE 'Standardhost'
    END AS host_tier,
    
    -- Metadata
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM stg_host