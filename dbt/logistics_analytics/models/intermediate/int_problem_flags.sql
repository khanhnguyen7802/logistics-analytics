{{ config(materialized='table') }}

with trips as (
    select * from {{ ref('int_trip_timeliness') }}
),

routes as (
    select * from {{ ref('int_route_performance') }}
),

vehicle_daily as (
    select * from {{ ref('int_vehicle_utilization') }}
),

combined as (
    select
        t.booking_id,
        t.booking_date,
        t.origin_location_name,
        t.destination_location,
        t.supplier_name,
        t.vehicle_registration,
        t.vehicle_type,
        t.delay_minutes,
        t.timeliness_severity,
        r.route_risk_severity,
        vd.utilization_severity,
        case
            when t.timeliness_severity = 'critical'
              or r.route_risk_severity = 'critical'
              or vd.utilization_severity = 'critical' then 1
            else 0
        end as has_critical_issue
    from trips t
    left join routes r
      on t.origin_location_name = r.origin_location_name
      and t.destination_location = r.destination_location
    left join vehicle_daily vd
      on t.booking_date = vd.booking_date
      and t.vehicle_registration = vd.vehicle_registration
      and t.vehicle_type = vd.vehicle_type
)

select * from combined
