{{ config(materialized='view') }}

with base as (
    select * from {{ ref('int_trip_timeliness') }}
),

daily as (
    select
        -- dispatches are tracked daily
        {{ dbt_utils.generate_surrogate_key(['vehicle_registration', 'booking_date', 'vehicle_type']) }} as vehicle_day_id,
        booking_date,
        vehicle_registration,
        vehicle_type,
        max(min_kms_per_day) as min_kms_per_day,
        count(*) as trip_count,
        sum(transportation_distance_km) as total_distance_km,
        avg(on_time_flag) as on_time_rate,
        avg(delay_minutes) as avg_delay_minutes
    from base
    group by 1, 2, 3, 4
),

final as (
    select
        vehicle_day_id,
        booking_date,
        vehicle_registration,
        vehicle_type,
        min_kms_per_day,
        trip_count,
        round(total_distance_km, 2) as total_distance_km,
        round(on_time_rate, 4) as on_time_rate,
        round(avg_delay_minutes, 2) as avg_delay_minutes,
        
        case
            when min_kms_per_day <= 0 then null
            else round(total_distance_km / min_kms_per_day, 4) -- calculate the core KPI
        end as utilization_ratio,
        
        case
            when min_kms_per_day <= 0 then 'unknown' -- denominator is zero or negative
            when total_distance_km / min_kms_per_day < 0.60 then 'critical'
            when total_distance_km / min_kms_per_day < 0.80 then 'high'
            when total_distance_km / min_kms_per_day < 1.00 then 'medium'
            else 'healthy'
        end as utilization_severity
    from daily
)

select * from final
