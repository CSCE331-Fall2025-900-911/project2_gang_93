-- Special Query #4: Menu Item Inventory
-- Counts how many unique inventory items are required for each menu item.

SELECT
    m.menuItemName,
    jsonb_array_length(m.ingredients) AS ingredient_count
FROM
    menu m
ORDER BY
    m.menuItemName;
