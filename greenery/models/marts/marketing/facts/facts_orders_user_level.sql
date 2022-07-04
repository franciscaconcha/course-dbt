{{
    config(
        materialized = 'table'
        , unique_key = 'order_guid'
    )
}}

SELECT 
  o.order_guid
  , o.user_guid
  , o.promo_guid
  , o.created_at_utc AS order_created_at_utc
  , o.order_cost_usd
  , o.shipping_cost_usd
  , o.order_total_usd
  , o.tracking_id
  , o.shipping_service
  , o.estimated_delivery_at_utc
  , o.delivered_at_utc
  , o.order_status
  , u.first_name AS user_first_name
  , u.last_name AS user_last_name
  , u.email AS user_email
  , u.phone_number AS user_phone_number
  , u.created_at_utc AS user_created_at_utc
  , u.updated_at_utc AS user_updated_at_utc
  , u.address AS delivery_address
  , o.order_length
  , u.user_ltv_usd
  , u.is_repeat_user
  , u.number_of_orders 
FROM {{ ref('dim_orders') }} AS o
LEFT JOIN {{ ref('dim_users') }} AS u
  ON o.user_guid = u.user_guid
