{{ config(materialized='table') }}

select *,
      try_strptime(trip_start_date, '%m/%d/%y %H:%M') as trip_start_date,
      try_strptime(trip_end_date, '%m/%d/%y %H:%M') as trip_end_date,
from {{ ref('stg_logistics') }}
