{{ config(materialized='table') }}

with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['driver_name', 'driver_mobile_no']) }} as driver_id,
    driver_name,
    driver_mobile_no
from stg
where driver_name != 'Unknown'

