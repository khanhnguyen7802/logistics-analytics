{{ config(materialized='table') }}

select
    vehicle_day_id,
    booking_date,
    vehicle_registration,
    vehicle_type,
    min_kms_per_day,
    trip_count,
    total_distance_km,
    on_time_rate,
    avg_delay_minutes,
    utilization_ratio,
    utilization_severity
from {{ ref('int_vehicle_utilization') }}
where utilization_severity in ('medium', 'high', 'critical')
