WITH stg_host AS (
    SELECT * FROM `decamp-project-52560`.`ny_airbnb_staging_dataset`.`stg_host`
)

SELECT
    to_hex(md5(cast(coalesce(cast(host_id as string), '_dbt_utils_surrogate_key_null_') as string))) AS host_key,
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