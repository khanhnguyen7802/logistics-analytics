{{ config(materialized='table') }}

with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['material_name']) }} as material_id,
    material_name
from stg
where material_name != 'Unknown'
