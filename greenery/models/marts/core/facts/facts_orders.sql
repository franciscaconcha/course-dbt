{{
    config(
        materialized = 'incremental'
        , unique_key = 'order_guid'
    )
}}

SELECT 
  o.order_guid
  , o.user_guid
  , o.promo_guid
  , o.created_at_utc
  , o.order_cost_usd
  , o.shipping_cost_usd
  , o.order_total_usd
  , o.tracking_id
  , o.shipping_service
  , o.estimated_delivery_at_utc
  , o.delivered_at_utc
  , o.order_status
  , a.address AS delivery_address
  , ol.order_length
FROM {{ ref('stg_greenery__orders') }} AS o
LEFT JOIN {{ ref('stg_greenery__addresses') }} AS a
  ON o.address_guid = a.address_guid
LEFT JOIN {{ ref('int_order_length') }} AS ol
  ON o.order_guid = ol.order_guid