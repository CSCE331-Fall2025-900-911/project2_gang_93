-- Top 10 Customers with the Most Points
SELECT
    customerId,
    firstName,
    lastName,
    points
FROM customerRewards
ORDER BY points DESC
LIMIT 10;