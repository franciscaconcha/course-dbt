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
  , a.address AS delivery_address
  , o.order_length
  , ltv.user_ltv_usd
  , r.is_repeat_user
  , n.n_orders AS number_of_orders 
FROM {{ ref('facts_orders') }} AS o
LEFT JOIN {{ ref('stg_greenery__users') }} AS u
  ON o.user_guid = u.user_guid
LEFT JOIN {{ ref('stg_greenery__addresses') }} AS a
  ON u.address_guid = a.address_guid
LEFT JOIN {{ ref('int_users_ltv') }} AS ltv
  ON u.user_guid = ltv.user_guid
LEFT JOIN {{ ref('int_repeat_users') }} AS r
  ON u.user_guid = r.user_guid
LEFT JOIN {{ ref('int_number_of_orders_per_user') }} AS n
  ON u.user_guid = n.user_guid
