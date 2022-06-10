{{
    config(
        materialized = 'view'
        , unique_key = 'user_guid'
    )
}}

WITH users_source AS (
    SELECT * FROM {{ source('sources', 'users') }}
)

, rename_recast AS (
    SELECT
        user_id AS user_guid
        , first_name
        , last_name
        , email
        , phone_number
        , created_at AS created_at_utc
        , updates_at AS updated_at_utc
        , address_id AS address_guid
    FROM users_source
)

SELECT * from rename_recast