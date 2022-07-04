{{
    config(
        materialized = 'table'
        , unique_key = 'order_guid'
    )
}}

SELECT 
    o.order_guid
    , COUNT(*) AS number_of_items
FROM {{ ref('stg_greenery__orders') }} AS o
LEFT JOIN {{ ref('stg_greenery__order_items') }} AS i
  ON o.order_guid = i.order_guid
GROUP BY 1
