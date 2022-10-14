{{ config(materialized='table') }}

SELECT 
    date AS reportDate, 
    device.operatingSystem AS operationSystem,
    SUM(totals.pageviews) AS totalPageViews,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801` 
GROUP BY date, device.operatingSystem