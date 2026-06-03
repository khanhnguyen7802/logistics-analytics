{{ config(materialized='table') }}

with flags as (
    select * from {{ ref('int_problem_flags') }}
)

select
    booking_date,
    count(*) as total_trips,
    round(avg(case when timeliness_severity = 'on_time' then 1 else 0 end), 4) as on_time_rate,
    round(avg(delay_minutes), 2) as avg_delay_minutes,
    sum(case when timeliness_severity in ('high', 'critical') then 1 else 0 end) as high_delay_trip_count,
    sum(case when route_risk_severity in ('high', 'critical') then 1 else 0 end) as route_risk_trip_count,
    sum(case when utilization_severity in ('high', 'critical') then 1 else 0 end) as vehicle_underutilized_trip_count,
    sum(has_critical_issue) as critical_issue_trip_count
from flags
group by booking_date
