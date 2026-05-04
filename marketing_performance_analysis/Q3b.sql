-- Q3b: Installs, Cost & ROAS by Platform (fixed filtering)
WITH
  user_platform AS (
    SELECT
      u.user_id,
      CASE
        WHEN LOWER(t.tracker_name) LIKE '%facebook%'         THEN 'Facebook'
        WHEN LOWER(t.tracker_name) LIKE '%apple search ads%' THEN 'Apple Search Ads'
        WHEN LOWER(t.tracker_name) LIKE '%apple ads%'        THEN 'Apple Search Ads'
        WHEN LOWER(t.tracker_name) LIKE '%apple search%'     THEN 'Apple Search Ads'
        WHEN LOWER(t.tracker_name) =  'organic'              THEN 'Organic'
        ELSE NULL
      END AS platform
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
      ) AS revenue
    FROM
      `question3marketing.marketing.marketing_events` AS e,
      UNNEST(e.properties) AS p
    WHERE
      p.key = 'revenue'
  ),
  revenue_per_platform AS (
    SELECT
      up.platform,
      SUM(er.revenue) AS total_revenue
    FROM
      user_platform AS up
    JOIN
      event_revenue AS er
    USING (user_id)
    WHERE
      up.platform IN ('Facebook','Apple Search Ads')
    GROUP BY
      up.platform
  ),
  installs AS (
    SELECT
      platform,
      COUNT(DISTINCT user_id) AS installs
    FROM
      user_platform
    WHERE
      platform IN ('Facebook','Apple Search Ads')
    GROUP BY
      platform
  )
SELECT
  r.platform,
  i.installs,
  CASE
    WHEN r.platform = 'Facebook'         THEN 1.3
    WHEN r.platform = 'Apple Search Ads' THEN 3.1
  END AS CPI,
  i.installs *
    CASE
      WHEN r.platform = 'Facebook'         THEN 1.3
      WHEN r.platform = 'Apple Search Ads' THEN 3.1
    END AS total_cost,
  r.total_revenue,
  ROUND(
    r.total_revenue /
    (i.installs *
      CASE
        WHEN r.platform = 'Facebook'         THEN 1.3
        WHEN r.platform = 'Apple Search Ads' THEN 3.1
      END
    )
    , 2
  ) AS ROAS,
  ROUND(r.total_revenue / i.installs, 2) AS revenue_per_install
FROM
  revenue_per_platform AS r
JOIN
  installs AS i
USING (platform)
ORDER BY
  ROAS DESC;
