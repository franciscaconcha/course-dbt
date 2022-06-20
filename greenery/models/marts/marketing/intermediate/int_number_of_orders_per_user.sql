{{
    config(
        materialized = 'table'
        , unique_key = 'user_guid'
    )
}}


SELECT
    user_guid
    , COUNT(DISTINCT order_guid) AS n_orders
  FROM {{ ref('stg_greenery__orders') }}
  GROUP BY 1