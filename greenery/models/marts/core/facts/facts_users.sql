{{
    config(
        materialized = 'incremental'
        , unique_key = 'user_guid'
    )
}}

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
  , r.is_repeat_user
  , n.n_orders AS number_of_orders 
FROM {{ ref('stg_greenery__users') }} AS u
LEFT JOIN {{ ref('stg_greenery__addresses') }} AS a
  ON u.address_guid = a.address_guid
LEFT JOIN {{ ref('int_users_ltv') }} AS ltv
  ON u.user_guid = ltv.user_guid
LEFT JOIN {{ ref('int_repeat_users') }} AS r
  ON u.user_guid = r.user_guid
LEFT JOIN {{ ref('int_number_of_orders_per_user') }} AS n
  ON u.user_guid = n.user_guid