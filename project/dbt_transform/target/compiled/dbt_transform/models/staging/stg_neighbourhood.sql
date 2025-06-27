WITH neighbourhood AS (
    SELECT DISTINCT 
        neighbourhood_group,
        neighbourhood,
        latitude,
        longitude,
        CONCAT(neighbourhood_group, '-', neighbourhood) AS neighbourhood_id
    FROM `decamp-project-52560`.`raw_dataset`.`ny_airbnb_raw`
)
SELECT * FROM neighbourhood