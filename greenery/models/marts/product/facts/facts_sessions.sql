{{
    config(
        materialized = 'incremental'
        , unique_key = 'session_guid'
    )
}}

{%- set event_types = dbt_utils.get_column_values(
    table=ref('stg_greenery__events'),
    column='event_type'
) -%}

{% set cond_upper_funnel %}
  -- Has page view only: upper funnel
  {{aggregate_events( 'page_view' )}} > 0
  AND {{aggregate_events( 'add_to_cart' )}} = 0
  AND {{aggregate_events( 'checkout' )}} = 0
{% endset %}

{% set cond_mid_funnel %}
  -- Has page view and add to cart: mid funnel
  {{aggregate_events( 'page_view' )}} > 0
  AND {{aggregate_events( 'add_to_cart' )}} > 0
  AND {{aggregate_events( 'checkout' )}} = 0
{% endset %}

{% set cond_lower_funnel %}
  -- Has page view, add to cart, and checkout: lower funnel
  {{aggregate_events( 'page_view' )}} > 0
  AND {{aggregate_events( 'add_to_cart' )}} > 0
  AND {{aggregate_events( 'checkout' )}} > 0
{% endset %}

SELECT
  s.session_guid
  , s.session_start_at_utc
  , s.session_end_at_utc
  , s.session_length
  , e.user_guid
  , MAX(CASE WHEN e.order_guid IS NOT NULL THEN 1 ELSE 0 END) AS has_order
  {%- for event in event_types %}
  , {{aggregate_events( event )}} AS n_{{event}}
  {%- endfor %}
  , CASE 
      -- I'm putting the conditions from lower to upper,
      -- because I care about the last existing event
      -- to define the corresponding funnel level
      WHEN {{cond_lower_funnel}} THEN 'lower'
      WHEN {{cond_mid_funnel}} THEN 'mid'
      WHEN {{cond_upper_funnel}} THEN 'upper'
    END
    AS funnel_level
FROM {{ ref('int_session_length') }} AS s
LEFT JOIN {{ ref('stg_greenery__events') }} AS e
  ON s.session_guid = e.session_guid
GROUP BY 1, 2, 3, 4, 5