WITH host AS (
    SELECT DISTINCT 
        room_type
    FROM `decamp-project-52560`.`raw_dataset`.`ny_airbnb_raw`
),
host_with_id AS (
    SELECT 
        ROW_NUMBER() OVER () AS room_type_id,  -- Generates a unique ID
        room_type
    FROM host
)
SELECT * FROM host_with_id