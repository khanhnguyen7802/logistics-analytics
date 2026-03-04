{% macro handle_null_values(column, replacement) %}
  case 
    when {{ column }} is null then {{ replacement }}
    when upper(cast({{ column }} as varchar)) in ('NULL', 'NA', 'N/A') then {{ replacement }}
    when trim(cast({{ column }} as varchar)) = '' then {{ replacement }}
    else {{ column }}
  end
{% endmacro %}
