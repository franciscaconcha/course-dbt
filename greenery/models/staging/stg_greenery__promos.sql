{{
    config(
        materialized = 'view'
        , unique_key = 'promo_guid'
    )
}}

WITH promos_source AS (
    SELECT * FROM {{ source('sources', 'promos') }}
)

, rename_recast AS (
    SELECT
        promo_id AS promo_guid
        , discount AS promo_discount
        , status AS promo_status
    FROM promos_source
)

SELECT * from rename_recast