{{
    config(
        materialized = 'table'
        , unique_key = 'session_guid'
    )
}}

WITH session_timestamps AS (
  SELECT
    e.session_guid
    , u.user_guid
    , MIN(e.created_at_utc) AS session_start_at_utc
    , MAX(e.created_at_utc) AS session_end_at_utc
  FROM {{ ref('stg_greenery__events') }} AS e
  LEFT JOIN {{ ref('stg_greenery__users') }} AS u
    ON e.user_guid = u.user_guid
  GROUP BY 1, 2
)
SELECT
  session_guid
  , user_guid
  , session_start_at_utc
  , session_end_at_utc
  , (session_end_at_utc - session_start_at_utc) AS session_length
FROM session_timestamps