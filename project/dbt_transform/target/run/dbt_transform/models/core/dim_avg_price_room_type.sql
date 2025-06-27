
  
    

    create or replace table `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`dim_avg_price_room_type`
      
    
    

    OPTIONS()
    as (
      

with fact_data as (
    select * from `decamp-project-52560`.`ny_airbnb_analytics_dataset`.`fact_listings`
)
select
    room_type,
    avg(price) as avg_price
from fact_data
group by 1
    );
  