WITH host AS (
    SELECT DISTINCT 
        CAST(host_id AS STRING) AS host_id,
        host_name,
        calculated_host_listings_count as host_listings_count
    FROM `decamp-project-52560`.`raw_dataset`.`ny_airbnb_raw`
)
SELECT * FROM host