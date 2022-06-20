{{
    config(
        materialized = 'table'
        , unique_key = 'user_guid'
    )
}}


SELECT
    user_guid
    -- Flag to see if a user is a repeat user (2+ orders) or not
    , CASE
        WHEN n_orders >= 2 THEN True 
        ELSE False
      END AS is_repeat_user
  FROM {{ ref('int_number_of_orders_per_user') }}