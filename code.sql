-- Get a count of campaigns and sources
SELECT COUNT(DISTINCT utm_campaign) AS 'Campaign Count',
       COUNT(DISTINCT utm_source) AS 'Source Count'
FROM page_visits;
-- Determine the relationship between the campaigns and sources
SELECT DISTINCT utm_campaign AS Campaign,
                utm_source AS Source
FROM page_visits;
-- Find the distinct page names on the CoolTShirts website
SELECT DISTINCT page_name AS 'Page Names'
FROM page_visits;
-- Find the campaign and source responsible for each user's first touch
-- First we create a temp table that finds first touches
-- and groups them by user id
WITH first_touch AS (
     SELECT user_id,
            MIN(timestamp) AS first_touch_at
     FROM page_visits
     GROUP BY user_id),
-- Then we create a second temp table joining campaigns
-- and sources from the page_visits table on user_id and timestamp
     ft_attr AS (
     SELECT ft.user_id,
            ft.first_touch_at,
            pv.utm_campaign,
            pv.utm_source
     FROM first_touch ft
     JOIN page_visits pv
          ON ft.user_id = pv.user_id
          AND ft.first_touch_at = pv.timestamp)
-- Now we select and count the number of times each campaign and source
-- is responsible for a first touch
     SELECT ft_attr.utm_campaign AS 'Campaign',
            ft_attr.utm_source AS 'Source',
            COUNT(*) AS 'Count'
     FROM ft_attr
     GROUP BY 1, 2
     ORDER BY 3 DESC;
-- Find the campaign and source responsible for each user's last touch
-- First we create a temp table that finds last touches
-- and groups them by user_id
WITH last_touch AS (
     SELECT user_id,
            MAX(timestamp) AS last_touch_at
     FROM page_visits
     GROUP BY user_id),
-- Then we create a second temp table joining the campaigns and sources
-- from the page_visits table on user_id and timestamp
     lt_attr AS (
     SELECT lt.user_id,
            lt.last_touch_at,
            pv.utm_campaign,
            pv.utm_source
     FROM last_touch lt
     JOIN page_visits pv
          ON lt.user_id = pv.user_id
          AND lt.last_touch_at = pv.timestamp)
-- Now we select and count the number of times each campaign and source
-- is responsible for a last touch
     SELECT lt_attr.utm_campaign AS 'Campaign',
            lt_attr.utm_source AS 'Source',
            COUNT(*) AS 'Count'
     FROM lt_attr
     GROUP BY 1, 2
     ORDER BY 3 DESC;
-- Find the number of visitors who make a purchase
SELECT COUNT (DISTINCT user_id) AS 'Customers Making a Purchase'
FROM page_visits
WHERE page_name = '4 - purchase';
-- Find the number of LAST TOUCHES from each campaign
-- that result in a purchase
-- First we create a temp table to find last touches by user id
WITH last_touch AS (
     SELECT user_id,
            MAX(timestamp) AS last_touch_at
     FROM page_visits
-- WHERE clause focuses query to only users that make a purchase
     WHERE page_name = '4 - purchase'
     GROUP BY 1),
-- Now we create a second temp table joining our first
-- with the campaign and source columns from the page_visits table
lt_attr AS (
        SELECT lt.user_id,
               lt.last_touch_at,
               pv.utm_campaign,
               pv.utm_source
        FROM last_touch lt
        JOIN page_visits pv
             ON lt.user_id = pv.user_id
             AND lt.last_touch_at = pv.timestamp)
-- Finally we determine the number of purchases each campaign
-- is responsible for
SELECT lt_attr.utm_campaign AS 'Campaign',
       lt_attr.utm_source AS 'Source',
       COUNT(*) AS 'Count'
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;