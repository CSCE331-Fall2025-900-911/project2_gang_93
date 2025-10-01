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

-- ==============================================
-- Monthly Sale History
-- Orders count grouped by month
SELECT
    DATE_TRUNC('month', date)::DATE AS month_start,
    COUNT(*) AS total_orders
FROM transactions
GROUP BY month_start
ORDER BY month_start;


-- ==============================================
-- Best Performing Item Per Month
-- Top-selling menu item by quantity each month
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
ORDER BY month_start, total_qty DESC;


-- ==============================================
-- Total $ Made Per Month
SELECT
    DATE_TRUNC('month', t.date)::DATE AS month_start,
    SUM( (item->>'quantity')::INT * m.price ) AS monthly_sales
FROM transactions t
CROSS JOIN LATERAL jsonb_array_elements(t.items) AS item
JOIN menu m ON m.menuItemId = (item->>'menuItemId')::INT
GROUP BY month_start
ORDER BY month_start;


-- ==============================================
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


-- ==============================================
-- Most Common Used Inventory Item
-- Based on ingredients referenced in menu items sold
SELECT
    ing->>'ingredient' AS ingredient_name,
    COUNT(*) AS usage_count
FROM transactions t
CROSS JOIN LATERAL jsonb_array_elements(t.items) AS item
JOIN menu m ON m.menuItemId = (item->>'menuItemId')::INT
CROSS JOIN LATERAL jsonb_array_elements(m.ingredients) AS ing
GROUP BY ingredient_name
ORDER BY usage_count DESC
LIMIT 1;


-- ==============================================
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


-- ==============================================
-- Ranked Menu Item Per Month
-- Rank all menu items by total $ sales within each month
SELECT
    DATE_TRUNC('month', t.date)::DATE AS month_start,
    m.menuItemName,
    SUM( (item->>'quantity')::INT * m.price ) AS total_sales,
    RANK() OVER (PARTITION BY DATE_TRUNC('month', t.date) ORDER BY SUM((item->>'quantity')::INT * m.price) DESC) AS rank
FROM transactions t
CROSS JOIN LATERAL jsonb_array_elements(t.items) AS item
JOIN menu m ON m.menuItemId = (item->>'menuItemId')::INT
GROUP BY month_start, m.menuItemName
ORDER BY month_start, rank;
