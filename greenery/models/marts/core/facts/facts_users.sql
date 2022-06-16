{{
    config(
        materialized = 'incremental'
        , unique_key = 'user_guid'
    )
}}

SELECT 
  u.user_guid
  , ltv.user_ltv_usd
  , r.is_repeat_user
FROM dbt.dbt_fran_cr.stg_greenery__users AS u
LEFT JOIN dbt.dbt_fran_cr.int_users_ltv AS ltv
  ON u.user_guid = ltv.user_guid
LEFT JOIN dbt.dbt_fran_cr.int_repeat_users AS r
  ON u.user_guid = r.user_guid
;