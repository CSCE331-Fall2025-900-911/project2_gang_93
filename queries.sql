-- Special Query #1: Weekly Sales History
-- Count of orders grouped by week number
SELECT
    DATE_TRUNC('week', date)::DATE AS week_start,
    COUNT(*) AS total_orders
FROM transactions
GROUP BY week_start
ORDER BY week_start;

-- Special Query #2: Realistic Sales History
-- Orders grouped by HOUR of day, with total $ amount
SELECT
    DATE_PART('hour', t.date) AS order_hour,
    COUNT(*) AS total_orders,
    SUM( (item->>'quantity')::INT * m.price ) AS total_sales
FROM transactions t
CROSS JOIN LATERAL jsonb_array_elements(t.items) AS item
JOIN menu m ON m.menuItemId = (item->>'menuItemId')::INT
GROUP BY order_hour
ORDER BY order_hour;

-- Special Query #3: Peak Sales Day
-- Top 10 days by total sales
SELECT
    DATE(t.date) AS order_day,
    SUM( (item->>'quantity')::INT * m.price ) AS daily_total
FROM transactions t
CROSS JOIN LATERAL jsonb_array_elements(t.items) AS item
JOIN menu m ON m.menuItemId = (item->>'menuItemId')::INT
GROUP BY order_day
ORDER BY daily_total DESC
LIMIT 10;