{% test has_tracking_id(model, column_name) %}

    -- Test to check that all shipped orders have a tracking id
   select *
   from {{ model }}
   where {{ model }}.order_status = 'shipped'
   and {{ column_name }} is null


{% endtest %}