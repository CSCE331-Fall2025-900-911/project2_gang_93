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