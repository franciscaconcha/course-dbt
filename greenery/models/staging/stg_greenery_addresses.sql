{{
    config(
        materialized = 'view'
        , unique_key = 'address_guid'
    )
}}

WITH addresses_source AS (
    SELECT * FROM {{ source('sources', 'addresses') }}
)

, rename_recast AS (
    SELECT
        address_id AS address_guid
        , address
        , zipcode
        , state
        , country
    FROM addresses_source
)

SELECT * from rename_recast