-- psql --host=mydb.abcdefgh.us-east-1.rds.amazonaws.com \
--      --port=5432 \
--      --username=gang_93 \
--      --dbname=gamg_93_db


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


-- Special Query #4: Menu Item Inventory
-- Counts how many unique inventory items are required for each menu item.

SELECT
    m.menuItemName,
    jsonb_array_length(m.ingredients) AS ingredient_count
FROM
    menu m
ORDER BY
    m.menuItemName;


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



-- ==============================================
-- Top 10 Customers with the Most Points
SELECT
    customerId,
    firstName,
    lastName,
    points
FROM customerRewards
ORDER BY points DESC
LIMIT 10;


-- ==============================================
-- Customers' Birthdays Per Month
-- Shows how many customers have birthdays in each month
SELECT
    TO_CHAR(DOB, 'Month') AS month_name,
    COUNT(*) AS birthday_count
FROM customerRewards
GROUP BY month_name, DATE_PART('month', DOB)
ORDER BY DATE_PART('month', DOB);
