{{ config(materialized='table') }}

with stg as (
    select * from {{ ref('stg_logistics_cleaned') }}
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['customer_name']) }} as customer_id,
    customer_name
from stg
where customer_name != 'Unknown'


