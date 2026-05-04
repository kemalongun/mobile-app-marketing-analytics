-- Q3a: Total Revenue by Platform (formatted as requested)
WITH
  user_platform AS (
    SELECT
      u.user_id,
      CASE
        WHEN t.tracker_name LIKE '%Facebook%'         THEN 'Facebook'
        WHEN t.tracker_name LIKE '%Apple Search Ads%' THEN 'Apple Search'
        WHEN t.tracker_name LIKE '%Apple Ads%'        THEN 'Apple Search'
        WHEN t.tracker_name = 'Organic'               THEN 'Organic'
        ELSE NULL
      END AS Platform
    FROM
      `question3marketing.marketing.marketing_users` AS u,
      UNNEST(u.tracker_names) AS t
  ),
  event_revenue AS (
    SELECT
      e.user_id,
      SAFE_CAST(
        COALESCE(p.value.float_value, p.value.int_value)
        AS FLOAT64
      ) AS Revenue
    FROM
      `question3marketing.marketing.marketing_events` AS e,
      UNNEST(e.properties) AS p
    WHERE
      p.key = 'revenue'
  )
SELECT
  up.Platform,
  ROUND(SUM(er.Revenue), 2) AS Revenue
FROM
  user_platform AS up
JOIN
  event_revenue AS er
USING (user_id)
WHERE
  up.Platform IN ('Facebook', 'Apple Search', 'Organic')
GROUP BY
  up.Platform
ORDER BY
  up.Platform;
