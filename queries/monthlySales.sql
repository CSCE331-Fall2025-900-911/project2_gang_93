-- Monthly Sale History
-- Orders count grouped by month
SELECT
    DATE_TRUNC('month', date)::DATE AS month_start,
    COUNT(*) AS total_orders
FROM transactions
GROUP BY month_start
ORDER BY month_start;