-- Customers' Birthdays Per Month
-- Shows how many customers have birthdays in each month
SELECT
    TO_CHAR(DOB, 'Month') AS month_name,
    COUNT(*) AS birthday_count
FROM customerRewards
GROUP BY month_name, DATE_PART('month', DOB)
ORDER BY DATE_PART('month', DOB);