{{
    config(
        materialized = 'incremental'
        , unique_key = 'user_guid'
    )
}}

WITH n_orders_per_user AS (
    SELECT
    user_guid
    , COUNT(DISTINCT order_guid) AS n_orders
  FROM {{ ref('stg_greenery__orders') }}
  GROUP BY 1
)
, users_ltv AS (
    SELECT 
      u.user_guid
    , COALESCE(SUM(o.order_cost_usd), 0) AS user_ltv_usd
FROM {{ ref('stg_greenery__users') }} AS u
LEFT JOIN {{ ref('stg_greenery__orders') }} AS o
  ON u.user_guid = o.user_guid
GROUP BY 1
)

SELECT 
  u.user_guid
  , u.first_name
  , u.last_name
  , u.email
  , u.phone_number
  , u.created_at_utc
  , u.updated_at_utc
  , a.address
  , ltv.user_ltv_usd
  , n.n_orders AS number_of_orders 
  , CASE WHEN n.n_orders > 1 THEN True ELSE False END as is_repeat_user
FROM {{ ref('stg_greenery__users') }} AS u
LEFT JOIN {{ ref('stg_greenery__addresses') }} AS a
  ON u.address_guid = a.address_guid
LEFT JOIN users_ltv AS ltv
  ON u.user_guid = ltv.user_guid
LEFT JOIN n_orders_per_user AS n
  ON u.user_guid = n.user_guid