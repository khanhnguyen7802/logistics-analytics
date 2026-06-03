{{ config(materialized='table') }}

select
    route_id,
    origin_location_name,
    destination_location,
    trip_count,
    avg_distance_km,
    avg_delay_minutes,
    on_time_rate,
    avg_speed_kmh,
    route_risk_severity
from {{ ref('int_route_performance') }}
where route_risk_severity in ('medium', 'high', 'critical')
