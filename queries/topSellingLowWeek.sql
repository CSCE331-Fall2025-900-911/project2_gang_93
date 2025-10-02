-- Special Query #5: Best of the Worst
-- For each week, finds the day with the lowest total sales and identifies the top-selling item on that specific day.

WITH DailySales AS (
    SELECT
        t.date AS sale_date,
        SUM((item->>'quantity')::INT * m.price) AS daily_total
    FROM
        transactions t
    CROSS JOIN LATERAL
        jsonb_array_elements(t.items) AS item
    JOIN
        menu m ON m.menuItemId = (item->>'menuItemId')::INT
    GROUP BY
        sale_date
),
DailyTopSeller AS (
    SELECT
        t.date AS sale_date,
        m.menuItemName AS top_item,
        ROW_NUMBER() OVER(PARTITION BY t.date ORDER BY SUM((item->>'quantity')::INT) DESC) as rn
    FROM
        transactions t
    CROSS JOIN LATERAL
        jsonb_array_elements(t.items) AS item
    JOIN
        menu m ON m.menuItemId = (item->>'menuItemId')::INT
    GROUP BY
        t.date, m.menuItemName
),
RankedWeeklySales AS (
    SELECT
        DATE_TRUNC('week', ds.sale_date)::DATE AS week_start,
        ds.sale_date,
        ds.daily_total,
        dts.top_item,
        ROW_NUMBER() OVER(PARTITION BY DATE_TRUNC('week', ds.sale_date) ORDER BY ds.daily_total ASC) as sales_rank_in_week
    FROM
        DailySales ds
    JOIN
        DailyTopSeller dts ON ds.sale_date = dts.sale_date AND dts.rn = 1
)
SELECT
    week_start,
    sale_date AS lowest_sales_day,
    daily_total,
    top_item AS top_seller_on_that_day
FROM
    RankedWeeklySales
WHERE
    sales_rank_in_week = 1
ORDER BY
    week_start;