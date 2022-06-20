{{
    config(
        materialized = 'table'
        , unique_key = 'order_guid'
    )
}}

SELECT 
    order_guid
    , (delivered_at_utc - created_at_utc) AS order_length
  FROM {{ ref('stg_greenery__orders') }}
  WHERE order_status = 'delivered'
