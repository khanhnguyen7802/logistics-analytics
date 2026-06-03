with base as (
	select
		booking_date,
		extract(hour from booking_date) as booking_hour,
		{{ get_week_date('booking_date') }} as day_of_the_week
	from {{ ref('fct_trips') }}
	where booking_date is not null
)

select
	day_of_the_week,
	booking_hour,
	count(*) as booking_volume,
  case day_of_the_week
        when 'Mon' then 1
        when 'Tue' then 2
        when 'Wed' then 3
        when 'Thu' then 4
        when 'Fri' then 5
        when 'Sat' then 6
        when 'Sun' then 7
    end as day_sort_order
from base
group by 1, 2
order by
	day_sort_order,
	booking_hour
