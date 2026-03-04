{{ config(materialized='table') }}

with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['supplier_name']) }} as supplier_id,
    supplier_name
from stg
where supplier_name != 'Unknown'
