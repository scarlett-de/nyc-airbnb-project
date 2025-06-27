WITH stg_neighbourhood AS (
    SELECT * FROM {{ ref('stg_neighbourhood') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['neighbourhood_group', 'neighbourhood']) }} AS neighbourhood_key,
    neighbourhood_group,
    neighbourhood,
    CONCAT(neighbourhood_group, ' - ', neighbourhood) AS full_neighbourhood_name,
    latitude,
    longitude,
    
    -- Business logic only in dimension table
    CASE
        WHEN neighbourhood_group IN ('Manhattan', 'Brooklyn') THEN 'Prime'
        WHEN neighbourhood_group IN ('Queens', 'Bronx') THEN 'Secondary'
        ELSE 'Other'
    END AS area_classification,
    
    
    -- Additional business attributes
    ROUND(latitude, 4) AS latitude_rounded,
    ROUND(longitude, 4) AS longitude_rounded,
    
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM stg_neighbourhood
