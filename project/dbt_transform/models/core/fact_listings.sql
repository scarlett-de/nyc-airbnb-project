WITH listings AS (
    SELECT
        listing_name,
        price,
        listing_id,
        host_id,
        room_type,
        neighbourhood_group,
        neighbourhood,
        minimum_nights,
        number_of_reviews,
        last_review_date,
        reviews_per_month,
        calculated_host_listings_count,
        availability_365,
        latitude,
        longitude
    FROM {{ ref('stg_listings') }}
)

SELECT
   host_id,
  listing_id,
  listing_name,
   neighbourhood_group,
   neighbourhood,
    room_type,
  -- Facts/measures
  price,
  minimum_nights,
  number_of_reviews,
  reviews_per_month,
  availability_365,
  calculated_host_listings_count,
  
  -- Derived metrics
  price * availability_365 AS potential_annual_revenue,
  
  CASE 
    WHEN availability_365 = 0 THEN 0 
    ELSE ROUND(price * 365 / NULLIF(availability_365, 0), 2)
  END AS implied_daily_rate,
  
  -- Business flags
  CASE WHEN number_of_reviews > 0 THEN 1 ELSE 0 END AS has_reviews_flag,
  CASE WHEN last_review_date IS NULL THEN 1 ELSE 0 END AS never_reviewed_flag,
  CASE WHEN availability_365 = 0 THEN 1 ELSE 0 END AS fully_booked_flag,
  
  -- Temporal dimensions
  EXTRACT(YEAR FROM last_review_date) AS last_review_year,
  FORMAT_DATE('%Y-%m', last_review_date) AS last_review_ym,
  
  -- Geolocation
  latitude,
  longitude,
  
  -- Metadata
  CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM listings