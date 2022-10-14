{{ config(materialized='view') }}

SELECT 
    c.reportDate,
    c.operationSystem,
    c.distincCountCountry,
    t.totalPageViews
FROM {{ ref('1_distinct_country_count') }} AS c
JOIN {{ ref('2_total_page_views') }} AS t
ON c.reportDate = t.reportDate AND c.operationSystem = t.operationSystem