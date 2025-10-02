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
