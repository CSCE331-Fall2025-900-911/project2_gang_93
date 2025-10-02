-- Special Query #1: Weekly Sales History
-- Count of orders grouped by week number
SELECT
    DATE_TRUNC('week', date)::DATE AS week_start,
    COUNT(*) AS total_orders
FROM transactions
GROUP BY week_start
ORDER BY week_start;