# Week 3 answers
**What is our overall conversion rate?**

The overall conversion rate is 0.62

```
WITH all_sessions AS (
  -- All distinct session ids
  SELECT DISTINCT session_guid
  FROM dbt.dbt_fran_cr.facts_sessions
), converted_sessions AS (
  -- Distinct session ids only for sessions with an order
  SELECT DISTINCT session_guid
  FROM dbt.dbt_fran_cr.facts_sessions
  WHERE has_order = 1
)
SELECT 
  -- Conversion rate: N sessions with orders / N sessions
  COUNT(c.session_guid)::FLOAT / COUNT(a.session_guid)
FROM all_sessions AS a
LEFT JOIN converted_sessions AS c 
ON a.session_guid = c.session_guid
```

**What is our conversion rate by product?**

The average conversion rate per product is 0.46.
The conversion rate for each product is as follows:

| Product name | Conversion rate |
| --- | --- |
| Pothos | 0.32 |
| Bamboo | 0.52 |
| Philodendron | 0.47 |
| Monstera | 0.51 |
| String of pearls | 0.6 |
| ZZ Plant | 0.52 |
| Snake Plant | 0.39 |
| Orchid | 0.45 |
| Birds Nest Fern | 0.41 |
| Calathea Makoyana | 0.51 |
| Peace Lily | 0.40 |
| Bird of Paradise | 0.45 |
| Fiddle Leaf Fig | 0.47 |
| Ficus | 0.42 |
| Pilea Peperomioides | 0.46 |
| Angel Wings Begonia | 0.38 |
| Jade Plant | 0.47 |
| Arrow Head | 0.54 |
| Majesty Palm | 0.47 |
| Spider Plant | 0.47 |
| Money Tree | 0.46 |
| Cactus | 0.54 |
| Devil's Ivy | 0.48 |
| Alocasia Polly | 0.38 |
| Pink Anthurium | 0.41 |
| Dragon Tree | 0.46 |
| Aloe Vera | 0.49 |
| Rubber Plant | 0.5 |
| Ponytail Palm | 0.39 |
| Boston Fern | 0.41 |

```
WITH n_orders_per_product AS (
  -- Number of times each product guid has been ordered
  SELECT 
    product_guid
    , COUNT(*) AS n_orders
  FROM dbt.dbt_fran_cr.stg_greenery__order_items
  GROUP BY 1
)
, n_page_views_per_product AS (
  -- Number of times each product guid page has been viewed
  SELECT
    product_guid
    , COUNT(*) AS n_page_views
  FROM dbt.dbt_fran_cr.stg_greenery__events
  WHERE event_type = 'page_view'
  GROUP BY 1
)
, conversion_rate_per_product AS (
  -- Conversion rate per product guid
  SELECT
    p.product_guid
    , (o.n_orders::float / p.n_page_views) AS conversion_rate
  FROM n_page_views_per_product AS p 
  LEFT JOIN n_orders_per_product AS o
    ON p.product_guid = o.product_guid
)
-- Conversion rate per product
SELECT p.product_name, cr.conversion_rate
FROM conversion_rate_per_product AS cr
LEFT JOIN dbt.dbt_fran_cr.stg_greenery__products AS p
  ON cr.product_guid = p.product_guid
-- Average product conversion rate
-- SELECT AVG(conversion_rate)
-- FROM conversion_rate_per_product
```

**Why might certain products be converting at higher/lower rates than others?**

Popularity: some products might currently be on trend, and have a higher conversion rate right now. But conversion rate is not necessarily static :) 

Some products might just be useful with every order. Since Greenery delivers houseplants, something like plant soil or a pot liner might be added to many orders, regardless of the plant in the order. Or with flowers: different flowers bouquets might all get a popular vase added to the order. A particular plant or bouquet might have a low conversion rate, but products associated with them that can be ordered along with other products would have a much higher conversion rate.

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

Result:
| is_repeat_user | avg(order_length) |
| --- | --- |
| false | 4 days 03:16:21.818182 |
| true | 3 days 20:56:49.187279 |


 It does look that on average, order length is shorter for repeat users. Maybe if all orders where delivered more quickly we could have more repeat users.

 **Explain the marts models you added. Why did you organize the models in the way you did?**

 It was not straightforward to define the marts models since I felt that a lot of data was overlapping between core, marketing, and product. In the end I tried to keep orders and users as core, since they can be used by the whole company. For marketing I focused on relating orders with users, so that we can filter both at the same time more easily and make decisions for marketing campaigns. For product, I decided to focus on sessions and page views, which gives us an idea of how the users are browsing the website.

**What assumptions are you making about each model? (i.e. why are you adding each test?)**

For all models I am assuming a unique, not null primary key. I am also assuming that value data is correct, for example that there are no negative values on costs.

**Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?**

Not bad data per se but I found that order_guid is not a good primary key for stg_greenery__order_items, since an order can have more than one item. I defined a different primary key combining order and item ids.

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