
  
    

    create or replace table `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`dim_count_by_neighbour_group`
      
    
    

    OPTIONS()
    as (
      


with fact_data as (
    select * from `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`fact_listings`
),
neighbourhood as (
    select * from `decamp-project-52560`.`ny_airbnb_staging_dataset`.`stg_neighbourhood`
)
select
    neighbourhood_group,
    count(listing_id) as total_listings
from fact_data
join neighbourhood on fact_data.neighbourhood = neighbourhood.neighbourhood
group by neighbourhood_group
    );
  