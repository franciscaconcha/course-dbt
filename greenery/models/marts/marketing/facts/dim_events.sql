{{
    config(
        materialized = 'incremental'
        , unique_key = 'event_guid'
    )
}}

SELECT
  event_guid
  , session_guid
  , user_guid
  , page_url
  , created_at_utc
  , event_type
  , order_guid
  , product_guid
  , CASE 
      WHEN event_type = 'page_view' THEN 'upper'
      WHEN event_type = 'add_to_cart' THEN 'mid'
      WHEN event_type = 'checkout' THEN 'lower'
    END
    AS funnel_level
FROM {{ ref('stg_greenery__events') }}