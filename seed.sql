\copy employees FROM 'yourfilepath/db_population_csvs/employees.csv' DELIMITER ',' CSV HEADER;
\copy inventory FROM 'yourfilepath/db_population_csvs/inventory.csv' DELIMITER ',' CSV HEADER;
\copy menu FROM 'yourfilepath/db_population_csvs/menu.csv' DELIMITER ',' CSV HEADER;
\copy customerRewards FROM 'yourfilepath/db_population_csvs/customerRewards.csv' DELIMITER ',' CSV HEADER;
\copy transactions FROM 'yourfilepath/db_population_csvs/transactions.csv' DELIMITER ',' CSV HEADER;
\copy sales FROM 'yourfilepath/db_population_csvs/sales.csv' DELIMITER ',' CSV HEADER;