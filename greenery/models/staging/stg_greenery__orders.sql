{{
    config(
        materialized = 'view'
        , unique_key = 'order_guid'
    )
}}

WITH orders_source AS (
    SELECT * FROM {{ source('sources', 'orders') }}
)

, rename_recast AS (
    SELECT
        order_id AS order_guid
        , user_id AS user_guid
        , promo_id AS promo_guid
        , address_id AS address_guid
        , created_at AS created_at_utc
        , order_cost AS order_cost_usd
        , shipping_cost AS shipping_cost_usd
        , order_total AS order_total_usd
        , tracking_id
        , shipping_service
        , estimated_delivery_at AS estimated_delivery_at_uct
        , delivered_at AS delivered_at_utc
        , status AS order_status
    FROM orders_source
)

SELECT * from rename_recast