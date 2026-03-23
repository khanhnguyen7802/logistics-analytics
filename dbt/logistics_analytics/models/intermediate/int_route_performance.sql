{{ config(materialized='view') }}

with base as (
    select * from {{ ref('int_trip_timeliness') }}
),

-- Aggregate by route
aggregated as (
    select
        {{ dbt_utils.generate_surrogate_key(['origin_location_name', 'destination_location']) }} as route_id,
        origin_location_name,
        destination_location,
        count(*) as trip_count,
        avg(transportation_distance_km) as avg_distance_km,
        avg(delay_minutes) as avg_delay_minutes,
        avg(on_time_flag) as on_time_rate,
        avg(avg_speed_kmh) as avg_speed_kmh
    from base
    group by 1, 2, 3 -- group by route_id, origin_location_name, destination_location
),

-- TODO: check again the route_risk_severity
-- Classify route risk severity 
final as (
    select
        route_id,
        origin_location_name,
        destination_location,
        trip_count,
        round(avg_distance_km, 2) as avg_distance_km,
        round(avg_delay_minutes, 2) as avg_delay_minutes,
        round(on_time_rate, 4) as on_time_rate,
        round(avg_speed_kmh, 2) as avg_speed_kmh,
        case
            when trip_count < 5 then 'low_sample'
            when on_time_rate < 0.70 or coalesce(avg_delay_minutes, 0) > 120 then 'critical'
            when on_time_rate < 0.80 or coalesce(avg_delay_minutes, 0) > 60 then 'high'
            when on_time_rate < 0.90 or coalesce(avg_delay_minutes, 0) > 30 then 'medium'
            else 'stable'
        end as route_risk_severity
    from aggregated
)

select * from final
