{{
    config(
        materialized = 'incremental'
        , unique_key = 'session_guid'
    )
}}


SELECT
  s.session_guid
  , s.session_start_at_utc
  , s.session_end_at_utc
  , s.session_length
  , e.user_guid
  , CASE WHEN e.order_guid IS NOT NULL THEN 1 ELSE 0 END AS has_order
  , p.n_page_views
FROM {{ ref('int_session_length') }} AS s
LEFT JOIN {{ ref('stg_greenery__events') }} AS e
  ON s.session_guid = e.session_guid
LEFT JOIN {{ ref('int_session_page_views') }} AS p
  ON s.session_guid = p.session_guid
