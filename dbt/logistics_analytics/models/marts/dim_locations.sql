-- locations can be both origins and destinations -> union all 

{{ config(materialized='table') }}

with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
),
  origin as (
    select 
        origin_location_name as location_name,
        origin_location_latitude as latitude,
        origin_location_longitude as longitude
    from stg
    where origin_location_name != 'Unknown'
),
  destination as (
    select 
        destination_location as location_name,
        destination_location_latitude as latitude,
        destination_location_longitude as longitude
    from stg
    where destination_location != 'Unknown'
), 
  unioned as (
    select * from origin
    union all
    select * from destination
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['location_name', 'latitude', 'longitude']) }} as location_id,
    location_name,
    latitude,
    longitude
from unioned
