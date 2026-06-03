{{ config(materialized='table') }}

with base as (
    select * from {{ ref('int_trip_timeliness') }}
)

select 
    booking_id,
    supplier_name,
    transportation_distance,
    delay_minutes,
    trip_duration_minutes
from base