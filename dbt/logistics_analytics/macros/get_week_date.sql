{% macro get_week_date(date_column) -%}
case
	when weekday({{ date_column }}) = 0 then 'Mon'
	when weekday({{ date_column }}) = 1 then 'Tues'
	when weekday({{ date_column }}) = 2 then 'Wed'
	when weekday({{ date_column }}) = 3 then 'Thu'
	when weekday({{ date_column }}) = 4 then 'Fri'
	when weekday({{ date_column }}) = 5 then 'Sat'
	when weekday({{ date_column }}) = 6 then 'Sun'
end
{%- endmacro %}
