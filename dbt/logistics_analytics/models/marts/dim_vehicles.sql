{{ config(materialized='table') }}

with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['vehicle_registration']) }} as vehicle_id,
    vehicle_registration,
    vehicle_type,
    min_kms_per_day
from stg
where vehicle_registration != 'Unknown'