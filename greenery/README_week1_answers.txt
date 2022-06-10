How many users do we have?
130

SELECT COUNT(*)
FROM dbt.dbt_fran_cr.stg_greenery__users
;

-----------------------------------------------------------------

On average, how many orders do we receive per hour?
7.52

SELECT AVG(n_orders_per_hour)
FROM (
  -- orders per hour
  SELECT
    DATE_TRUNC('HOUR', o.created_at_utc) AS hour 
    , COUNT(*) AS n_orders_per_hour
  FROM dbt.dbt_fran_cr.stg_greenery__orders AS o
  GROUP BY hour
) AS orders_per_hour;

-----------------------------------------------------------------

On average, how long does an order take from being placed to being delivered?
3 days

SELECT AVG(delivery_time)
FROM (
    -- time difference from order created to delivery
    SELECT (delivered_at_utc - created_at_utc) AS delivery_time
    FROM dbt.dbt_fran_cr.stg_greenery__orders
    WHERE order_status = 'delivered') AS delivery_times
;

-------------------------------------------------------------------

How many users have only made one purchase? Two purchases? Three+ purchases?
Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.

1 purchase: 25 users
2 purchases: 28 users
3+ purchases: 71 users

SELECT COUNT(*)
FROM (
  -- number of purchases per user
  SELECT user_guid, COUNT(order_guid) as n_orders
  FROM dbt.dbt_fran_cr.stg_greenery__orders
  GROUP BY user_guid) AS n_orders_per_user
WHERE n_orders = 1
-- WHERE n_orders = 2
-- WHERE n_orders >= 3;

-------------------------------------------------------------------

On average, how many unique sessions do we have per hour?
16.3

SELECT AVG(sessions_in_hour)
FROM
  (-- unique sessions per hour
  SELECT 
  DATE_TRUNC('HOUR', created_at_utc) AS hour
  , COUNT(DISTINCT session_guid) AS sessions_in_hour
  FROM dbt.dbt_fran_cr.stg_greenery__events
  GROUP BY hour) AS sessions_per_hour
;
