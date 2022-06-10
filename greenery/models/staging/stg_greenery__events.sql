{{
    config(
        materialized = 'view'
        , unique_key = 'address_guid'
    )
}}

WITH events_source AS (
    SELECT * FROM {{ source('sources', 'events') }}
)

, rename_recast AS (
    SELECT
        event_id AS event_guid
        , session_id AS session_guid
        , user_id AS user_guid
        , page_url
        , created_at AS created_at_utc
        , event_type
        , order_id AS order_guid
        , product_id AS product_guid
    FROM events_source
)

SELECT * from rename_recast