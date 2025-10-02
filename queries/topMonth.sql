-- Top Month by Total Sales
SELECT
    DATE_TRUNC('month', t.date)::DATE AS month_start,
    SUM( (item->>'quantity')::INT * m.price ) AS monthly_sales
FROM transactions t
CROSS JOIN LATERAL jsonb_array_elements(t.items) AS item
JOIN menu m ON m.menuItemId = (item->>'menuItemId')::INT
GROUP BY month_start
ORDER BY monthly_sales DESC
LIMIT 1;