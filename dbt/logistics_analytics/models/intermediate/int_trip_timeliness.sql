{{ config(materialized='view') }}

with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
),

prepared as (
    select
        booking_id,
        booking_date,
        supplier_name,
        customer_name,
        vehicle_registration,
        vehicle_type,
        min_kms_per_day,
        origin_location_name,
        destination_location,
        shipment_type,
        transportation_distance,
        trip_start_date,
        estimated_trip_end_date,
        planned_eta,
        actual_eta,
        on_time
    from stg
),

final as (
    select
        booking_id,
        booking_date,
        supplier_name,
        customer_name,
        vehicle_registration,
        vehicle_type,
        min_kms_per_day,
        origin_location_name,
        destination_location,
        shipment_type,
        transportation_distance,
        trip_start_date,
        estimated_trip_end_date,
        planned_eta,
        actual_eta,
        case
            when on_time = 'Yes' then 1
            else 0
        end as on_time_flag,

        -- Calculate delay in minutes (negative means early, positive means late)
        case
            when planned_eta is not null and actual_eta is not null then datediff('minute', planned_eta, actual_eta)
            else null
        end as delay_minutes,
        
        -- Calculate trip duration in minutes
        case
            when trip_start_date is not null and actual_eta is not null then datediff('minute', trip_start_date, actual_eta)
            else null
        end as trip_duration_minutes,
        
        -- Calculate average speed in km/h
        case
            when trip_start_date is not null and actual_eta is not null
            and datediff('minute', trip_start_date, actual_eta) > 0
            then transportation_distance / (datediff('minute', trip_start_date, actual_eta) / 60.0)
            else null
        end as avg_speed_kmh,
        
        -- TODO: check if the thresholds are reasonable or need adjustment based on data distribution
        -- Classify timeliness severity
        case
            when planned_eta is null or actual_eta is null then 'unknown'
            when datediff('minute', planned_eta, actual_eta) <= 0 then 'on_time'
            when datediff('minute', planned_eta, actual_eta) <= 60 then 'medium'
            when datediff('minute', planned_eta, actual_eta) <= 180 then 'high'
            else 'critical'
        end as timeliness_severity
    from prepared
)

select * from final
