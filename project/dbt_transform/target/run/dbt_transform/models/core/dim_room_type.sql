
  
    

    create or replace table `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`dim_room_type`
      
    
    

    OPTIONS()
    as (
      WITH stg_room_type AS (
    SELECT * FROM `decamp-project-52560`.`ny_airbnb_staging_dataset`.`stg_room_type`
)

SELECT
    to_hex(md5(cast(coalesce(cast(room_type as string), '_dbt_utils_surrogate_key_null_') as string))) AS room_type_key,
    room_type,
    
    -- Business logic only in dimension table
    CASE
        WHEN room_type = 'Entire home/apt' THEN 'Entire home/apartment'
        WHEN room_type = 'Private room' THEN 'Private room'
        WHEN room_type = 'Shared room' THEN 'Shared room'
        ELSE 'Other'
    END AS room_type_description,
    
    CASE
        WHEN room_type = 'Entire home/apt' THEN 1
        WHEN room_type = 'Private room' THEN 2
        WHEN room_type = 'Shared room' THEN 3
        ELSE 99
    END AS room_type_code,
    
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM stg_room_type
    );
  