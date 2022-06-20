{{
    config(
        materialized = 'incremental'
        , unique_key = 'session_guid'
    )
}}


SELECT
  session_guid
  , SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) AS n_page_views
FROM {{ ref('stg_greenery__events') }}
GROUP BY 1