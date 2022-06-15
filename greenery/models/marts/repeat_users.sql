{{
    config(
        materialized = 'table'
        , unique_key = 'user_guid'
    )
}}

-- Begin by calculating the number of orders per user
WITH n_orders_per_user AS (
  SELECT
    user_guid
    , COUNT(DISTINCT order_guid) AS n_orders
  FROM dbt.dbt_fran_cr.stg_greenery__orders
  GROUP BY 1
)
-- For users with 2+ orders, we set up the 'is_repeat_user' flag to True
, repeat_users AS (
  SELECT
    user_guid
    -- Flag to see if a user is a repeat user (2+ orders) or not
    , CASE
        WHEN n_orders >= 2 THEN True 
        ELSE False
      END AS is_repeat_user
  FROM n_orders_per_user
)
SELECT * FROM repeat_users