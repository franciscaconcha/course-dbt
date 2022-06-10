{{
    config(
        materialized = 'view'
        , unique_key = 'product_guid'
    )
}}

WITH products_source AS (
    SELECT * FROM {{ source('sources', 'products') }}
)

, rename_recast AS (
    SELECT
        product_id AS product_guid
        , name AS product_name
        , price AS product_price_usd
        , inventory AS product_inventory
    FROM products_source
)

SELECT * from rename_recast