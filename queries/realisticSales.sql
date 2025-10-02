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