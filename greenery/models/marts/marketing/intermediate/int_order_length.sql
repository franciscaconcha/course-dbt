{{
    config(
        materialized = 'table'
        , unique_key = 'order_guid'
    )
}}

 WITH order_length AS (
  SELECT 
    user_guid
    , order_guid
    , (delivered_at_utc - created_at_utc) AS order_length
  FROM dbt.dbt_fran_cr.stg_greenery__orders
  WHERE order_status = 'delivered'
)