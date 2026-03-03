{{ config(materialized='view') }}

with raw_data as (
    select * from {{ source('raw_data', 'tracking_data') }}
)

select
    -- IDs
    nullif("Booking ID", 'NULL')::varchar as booking_id,
    
    -- Entities (Natural Keys)
    nullif("Vehicle Registration", 'NULL')::varchar as vehicle_registration,
    nullif("Driver Name", 'NULL') as driver_name,
    nullif("Driver Mobile No", 'NULL') as driver_mobile_no,
    nullif("Customer Name", 'NULL') as customer_name,
    nullif("Supplier Name", 'NULL') as supplier_name,
    nullif("Material Shipped", 'NULL') as material_name,
    
    -- Locations
    nullif("Origin Location", 'NULL') as origin_location_name,
    "Origin Location Latitude"::double as origin_location_latitude,
    "Origin Location Longitude"::double as origin_location_longitude,
    nullif("Destination Location", 'NULL') as destination_location,
    "Destination Location Latitude"::double as destination_location_latitude,
    "Destination Location Longitude"::double as destination_location_longitude,
    
    -- GPS & Tracking
    nullif("Gps Provider", 'NULL') as gps_provider,
    nullif("Data Ping time", 'NULL') as data_ping_time,
    nullif("Current Location", 'NULL') as current_location,
    nullif("Current Location Latitude", 'NULL')::double as current_location_latitude,
    nullif("Curren Location Longitude", 'NULL')::double as current_location_longitude, 
    
    -- Trip Metrics & Dates
    nullif("Shipment Type", 'NULL') as shipment_type,
    (nullif("Transportation Distance (KM)", 'NULL'))::float as transportation_distance,
    "Ontime" as on_time,
    "Booking Date"::date as booking_date,
    nullif("Trip Start Date", 'NULL') as trip_start_date,
    nullif("Trip End Date", 'NULL') as trip_end_date,
    nullif("Planned ETA", 'NULL') as planned_eta,
    nullif("Actual ETA", 'NULL') as actual_eta,
    
    -- Vehicle specifics
    nullif("Vehicle Type", 'NULL') as vehicle_type,
    nullif("Minimum Kms To Be Covered In A Day", 'NULL')::float as min_kms_per_day

from raw_data