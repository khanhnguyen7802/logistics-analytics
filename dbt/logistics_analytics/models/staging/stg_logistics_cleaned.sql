{{ config(materialized='table') }}

select 
    booking_id,
    
    -- Entities (Natural Keys)
    {{ handle_null_values('vehicle_registration', "'Unknown'") }} as vehicle_registration,
    {{ handle_null_values('driver_name', "'Unknown'") }} as driver_name, 
    {{ handle_null_values('driver_mobile_no', "'Unknown'") }} as driver_mobile_no, 
    {{ handle_null_values('customer_name', "'Unknown'") }} as customer_name,  
    {{ handle_null_values('supplier_name', "'Unknown'") }} as supplier_name,
    {{ handle_null_values('material_name', "'Unknown'") }} as material_name,
    
    -- departure & destination
    {{ handle_null_values('origin_location_name', "'Unknown'") }} as origin_location_name,
    {{ handle_null_values('destination_location', "'Unknown'") }} as destination_location,

    -- coordinates
    origin_location_latitude,
    origin_location_longitude,
    destination_location_latitude,
    destination_location_longitude,
    
    -- GPS & Tracking
    {{ handle_null_values('gps_provider', "'Unknown'") }} as gps_provider,
    data_ping_time, -- dont know what to do with this yet 
    {{ handle_null_values('current_location', "'Unknown'") }} as current_location,
    current_location_latitude,
    current_location_longitude, 
    
    -- Trip Metrics & Dates
    shipment_type,
    transportation_distance,
    on_time,
    booking_date,
    try_strptime(trip_start_date, '%m/%d/%y %H:%M') as trip_start_date,
    try_strptime(trip_end_date, '%m/%d/%y %H:%M') as trip_end_date,
    planned_eta,
    try_strptime(actual_eta, '%m/%d/%y %H:%M') as actual_eta,
    
    -- Vehicle specifics
    {{ handle_null_values('vehicle_type', "'Unknown'") }} as vehicle_type,
    {{ handle_null_values('min_kms_per_day', -1) }} as min_kms_per_day,
from {{ ref('stg_logistics') }}
