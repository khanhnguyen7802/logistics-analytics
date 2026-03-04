with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
)

select
    -- Primary Key
    booking_id,

    -- Foreign Keys (since md5 hashing produces the same output for the same input, we can use it to generate consistent surrogate keys for our dimensions)
    {{ dbt_utils.generate_surrogate_key(['vehicle_registration']) }} as vehicle_id,
    {{ dbt_utils.generate_surrogate_key(['driver_name', 'driver_mobile_no']) }} as driver_id,
    {{ dbt_utils.generate_surrogate_key(['customer_name']) }} as customer_id,
    {{ dbt_utils.generate_surrogate_key(['supplier_name']) }} as supplier_id,
    {{ dbt_utils.generate_surrogate_key(['material_name']) }} as material_id,
    {{ dbt_utils.generate_surrogate_key(['origin_location_name', 'origin_location_latitude', 'origin_location_longitude']) }} as origin_location_id,
    {{ dbt_utils.generate_surrogate_key(['destination_location', 'destination_location_latitude', 'destination_location_longitude']) }} as destination_location_id,

    -- Trip Attributes and Metrics
    shipment_type,
    transportation_distance as transportation_distance_km,
    on_time,

    -- Timestamps
    booking_date,
    trip_start_date,
    trip_end_date,
    planned_eta,
    actual_eta

from stg
