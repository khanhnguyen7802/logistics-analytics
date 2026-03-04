with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['booking_id', 'data_ping_time']) }} as tracking_id,
    
    booking_id,
    gps_provider,
    data_ping_time,
    current_location,
    current_location_latitude,
    current_location_longitude

from stg
where data_ping_time is not null