{{
    config(
        materialized = 'incremental'
        , unique_key = 'user_guid'
    )
}}

SELECT 
  u.user_guid
  , COALESCE(SUM(o.order_cost_usd), 0) AS user_ltv_usd
FROM {{ ref('stg_greenery__users') }} AS u
LEFT JOIN {{ ref('stg_greenery__orders') }} AS o
  ON u.user_guid = o.user_guid
GROUP BY 1
