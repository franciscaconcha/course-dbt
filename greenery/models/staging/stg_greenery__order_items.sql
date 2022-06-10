{{
    config(
        materialized = 'view'
        , unique_key = 'order_guid'
    )
}}

WITH order_items_source AS (
    SELECT * FROM {{ source('sources', 'order_items') }}
)

, rename_recast AS (
    SELECT
        order_id AS order_guid
        , product_id AS product_guid
        , quantity
    FROM order_items_source
)

SELECT * from rename_recast