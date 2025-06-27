WITH source AS (
    SELECT 
        id AS listing_id,
        name AS listing_name,
        host_id,
        room_type,
        neighbourhood_group,
        neighbourhood,
        host_name,
        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,
        CAST(price AS NUMERIC) AS price,  
        minimum_nights,  
        number_of_reviews, 
        last_review as last_review_date,
        reviews_per_month,  
        calculated_host_listings_count,  
        availability_365 
    FROM `decamp-project-52560`.`raw_dataset`.`ny_airbnb_raw`
)

SELECT * FROM source