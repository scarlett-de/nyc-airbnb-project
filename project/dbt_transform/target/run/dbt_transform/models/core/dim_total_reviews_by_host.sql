
  
    

    create or replace table `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`dim_total_reviews_by_host`
      
    
    

    OPTIONS()
    as (
      

with fact_data as (
    select * from `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`fact_listings`
)
select
    host_id,
    sum(reviews_per_month) as total_reviews
from fact_data
group by 1
    );
  