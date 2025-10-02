-- Ranked Menu Item Per Month
-- Rank all menu items by total $ sales within each month
WITH MonthlySales AS (
    SELECT
        DATE_TRUNC('month', t.date)::DATE AS month_start,
        m.menuItemName,
        SUM((item->>'quantity')::INT * m.price) AS total_sales
    FROM
        transactions t
    CROSS JOIN LATERAL
        jsonb_array_elements(t.items) AS item
    JOIN
        menu m ON m.menuItemId = (item->>'menuItemId')::INT
    GROUP BY
        month_start, m.menuItemName
)
SELECT
    month_start,
    menuItemName,
    total_sales,
    RANK() OVER (PARTITION BY month_start ORDER BY total_sales DESC) AS rank
FROM
    MonthlySales
ORDER BY
    month_start, rank;