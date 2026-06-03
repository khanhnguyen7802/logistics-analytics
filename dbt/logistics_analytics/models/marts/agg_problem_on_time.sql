{{ config(materialized='table') }}

with base as (
    select * from {{ ref('int_trip_timeliness') }}
)

select
    booking_id,
    booking_date,
    supplier_name,
    vehicle_registration,
    origin_location_name,
    destination_location,
    transportation_distance,
    delay_minutes,
    trip_duration_minutes,
    avg_speed_kmh,
    timeliness_severity
from base
where timeliness_severity in ('medium', 'high', 'critical')
