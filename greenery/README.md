# Week 2 answers
**What is our user repeat rate?**

0.79

```
WITH n_orders_per_user AS (
  SELECT
    user_guid
    , COUNT(DISTINCT order_guid) AS n_orders
  FROM dbt.dbt_fran_cr.stg_greenery__orders
  GROUP BY 1
),
repeat_users AS (
  SELECT 
    user_guid
  FROM n_orders_per_user
  WHERE n_orders >= 2
)
--SELECT COUNT(*) FROM repeat_users --99
SELECT COUNT(*) FROM n_orders_per_user --124
-- 99/124 = 0.79
```

**What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?**

Some things that I would look into:
* What are items that users with 2+ orders have purchased? Are certain items more likely to mean a user might make more than 1 purchase?
* Does the time between order placement and delivery affect this? I would investigate if users with only 1 order had a long gap betnween order placement and delivery
 
 Lets look at some data:
 ```
 WITH order_length AS (
  SELECT 
    user_guid
    , order_guid
    , (delivered_at_utc - created_at_utc) AS order_length
  FROM dbt.dbt_fran_cr.stg_greenery__orders
  WHERE order_status = 'delivered'
)
, n_orders_per_user AS (
  SELECT
    user_guid
    , COUNT(DISTINCT order_guid) AS n_orders
  FROM dbt.dbt_fran_cr.stg_greenery__orders
  GROUP BY 1
)
, repeat_users AS (
  SELECT
    user_guid
    -- Flag to see if a user is a repeat user (2+ orders) or not
    , CASE
        WHEN n_orders >= 2 THEN True 
        ELSE False
      END AS is_repeat_user
  FROM n_orders_per_user
)
-- Compare the avg order length for repeat users vs non repeat users
SELECT 
  r.is_repeat_user,
  AVG(ol.order_length)
FROM order_length ol
LEFT JOIN repeat_users r
ON ol.user_guid = r.user_guid
GROUP BY 1
ORDER BY 1 ASC
 ```

 It does look that on average, order length is shorter for repeat users. Maybe if all orders where delivered more quickly we could have more repeat users.

# Week 1 answers
**How many users do we have?**

130

```
SELECT COUNT(*)
FROM dbt.dbt_fran_cr.stg_greenery__users
```

-----------------------------------------------------------------

**On average, how many orders do we receive per hour?**

7.52

```
SELECT AVG(n_orders_per_hour)
FROM (
  -- orders per hour
  SELECT
    DATE_TRUNC('HOUR', o.created_at_utc) AS hour 
    , COUNT(*) AS n_orders_per_hour
  FROM dbt.dbt_fran_cr.stg_greenery__orders AS o
  GROUP BY hour
) AS orders_per_hour;
```

-----------------------------------------------------------------

**On average, how long does an order take from being placed to being delivered?**

3 days

```
SELECT AVG(delivery_time)
FROM (
    -- time difference from order created to delivery
    SELECT (delivered_at_utc - created_at_utc) AS delivery_time
    FROM dbt.dbt_fran_cr.stg_greenery__orders
    WHERE order_status = 'delivered') AS delivery_times
;
```
-------------------------------------------------------------------

**How many users have only made one purchase? Two purchases? Three+ purchases?
Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.**

1 purchase: 25 users
2 purchases: 28 users
3+ purchases: 71 users

```
SELECT COUNT(*)
FROM (
  -- number of purchases per user
  SELECT user_guid, COUNT(order_guid) as n_orders
  FROM dbt.dbt_fran_cr.stg_greenery__orders
  GROUP BY user_guid) AS n_orders_per_user
WHERE n_orders = 1
-- WHERE n_orders = 2
-- WHERE n_orders >= 3;
```

-------------------------------------------------------------------

**On average, how many unique sessions do we have per hour?**

16.3

```
SELECT AVG(sessions_in_hour)
FROM
  (-- unique sessions per hour
  SELECT 
  DATE_TRUNC('HOUR', created_at_utc) AS hour
  , COUNT(DISTINCT session_guid) AS sessions_in_hour
  FROM dbt.dbt_fran_cr.stg_greenery__events
  GROUP BY hour) AS sessions_per_hour
;
```