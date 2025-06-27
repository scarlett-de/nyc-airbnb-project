
  
    

    create or replace table `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`dim_neighbourhood`
      
    
    

    OPTIONS()
    as (
      WITH stg_neighbourhood AS (
    SELECT * FROM `decamp-project-52560`.`ny_airbnb_staging_dataset`.`stg_neighbourhood`
)

SELECT
    to_hex(md5(cast(coalesce(cast(neighbourhood_group as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(neighbourhood as string), '_dbt_utils_surrogate_key_null_') as string))) AS neighbourhood_key,
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
    );
  