{{ config(materialized='view') }}

with raw_data as (
    select * from {{ source('raw_data', 'tracking_data') }}
)

select
    -- IDs
    try_cast(nullif(trim(cast("Booking ID" as varchar)), 'NULL') as varchar) as booking_id,
    
    -- Entities (Natural Keys)
    nullif("Vehicle Registration", 'NULL')::varchar as vehicle_registration,
    nullif("Driver Name", 'NULL') as driver_name,
    case
        when upper(trim(cast("Driver Mobile No" as varchar))) in ('NULL', 'NA', 'N/A', '') then null
        else trim(cast("Driver Mobile No" as varchar))
    end as driver_mobile_no,
    nullif("Customer Name", 'NULL') as customer_name,
    nullif("Supplier Name", 'NULL') as supplier_name,
    nullif("Material Shipped", 'NULL') as material_name,
    
    -- Locations
    nullif("Origin Location", 'NULL') as origin_location_name,
    try_cast("Origin Location Latitude" as double) as origin_location_latitude,
    try_cast("Origin Location Longitude" as double) as origin_location_longitude,
    nullif("Destination Location", 'NULL') as destination_location,
    try_cast("Destination Location Latitude" as double) as destination_location_latitude,
    try_cast("Destination Location Longitude" as double) as destination_location_longitude,
    
    -- GPS & Tracking
    nullif("Gps Provider", 'NULL') as gps_provider,
    "Data Ping time" as data_ping_time,
    nullif("Current Location", 'NULL') as current_location,
    try_cast("Current Location Latitude" as double) as current_location_latitude,
    try_cast("Curren Location Longitude" as double) as current_location_longitude, 
    
    -- Trip Metrics & Dates
    nullif("Shipment Type", 'NULL') as shipment_type,
    try_cast("Transportation Distance (KM)" as float) as transportation_distance,
    "Ontime" as on_time,
    try_cast("Booking Date" as timestamp) as booking_date,
    try_cast("Trip Start Date" as timestamp) as trip_start_date,
    try_cast("Trip End Date" as timestamp) as trip_end_date,
    try_cast("Planned ETA" as timestamp) as planned_eta,
    try_cast("Actual ETA" as timestamp) as actual_eta,
    
    -- Vehicle specifics
    nullif("Vehicle Type", 'NULL') as vehicle_type,
    try_cast("Minimum Kms To Be Covered In A Day" as float) as min_kms_per_day

from raw_data