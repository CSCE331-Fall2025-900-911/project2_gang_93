-- Worst Performing Item Per Month
-- Item with lowest total sales (quantity) each month
WITH item_sales AS (
    SELECT
        DATE_TRUNC('month', t.date)::DATE AS month_start,
        m.menuItemName,
        SUM( (item->>'quantity')::INT ) AS total_qty
    FROM transactions t
    CROSS JOIN LATERAL jsonb_array_elements(t.items) AS item
    JOIN menu m ON m.menuItemId = (item->>'menuItemId')::INT
    GROUP BY month_start, m.menuItemName
)
SELECT DISTINCT ON (month_start)
    month_start,
    menuItemName,
    total_qty
FROM item_sales
ORDER BY month_start, total_qty ASC;