import datetime
import random
import json
import numpy as np
import sys
import time
import csv
import os

OUTPUT_DIRECTORY = "db_population_csvs"

NUM_WEEKS = 39
TOTAL_SALES_TARGET = 760000
NUM_PEAK_DAYS = 1
NUM_EMPLOYEES = 15
NUM_CUSTOMERS = 1000

START_DATE = datetime.datetime.now() - datetime.timedelta(weeks=NUM_WEEKS)
PEAK_DAY = datetime.datetime(2024, 8, 26)

INVENTORY_ITEMS = [
    (2001, 'Black Tea Leaves (oz)', 50000), (2002, 'Taro Powder (oz)', 30000),
    (2003, 'Matcha Powder (oz)', 25000), (2004, 'Whole Milk (gallons)', 10000),
    (2005, 'Tapioca Pearls (oz)', 100000), (2006, 'Brown Sugar Syrup (L)', 8000),
    (2007, 'Oolong Tea Leaves (oz)', 40000), (2008, 'Coffee Beans (oz)', 60000),
    (2009, '16oz Cups', 80000), (2010, '24oz Cups', 80000), (2011, 'Lids', 160000),
    (2012, 'Straws', 200000), (2013, 'Napkins (count)', 150000), (2014, 'Coffee Jelly (oz)', 15000),
    (2015, 'Green Tea Leaves (oz)', 40000), (2016, 'Sugar (lbs)', 20000),
    (2017, 'Strawberry Puree (L)', 5000), (2018, 'Mango Puree (L)', 5000),
    (2019, 'Passion Fruit Syrup (L)', 5000), (2020, 'Caramel Syrup (L)', 4000),
    (2021, 'Wintermelon Syrup (L)', 4000), (2022, 'Thai Tea Mix (oz)', 10000),
    (2023, 'Honeydew Powder (oz)', 8000), (2024, 'Lychee Syrup (L)', 5000),
    (2025, 'Peach Syrup (L)', 5000), (2026, 'Espresso Shot (unit)', 10000),
    (2027, 'Cream Cheese Foam (L)', 1000), (2028, 'Almond Milk (gallons)', 2000),
    (2029, 'Whipped Cream (can)', 500)
]
SERVING_WARE = [{'itemId': 2009, 'qty': 1}, {'itemId': 2011, 'qty': 1}, {'itemId': 2012, 'qty': 1}]
MENU_ITEMS = [
    {'id': 101, 'name': 'Classic Milk Tea', 'price': 5.25, 'ingredients': SERVING_WARE + [{'itemId': 2001, 'qty': 0.5}, {'itemId': 2004, 'qty': 0.01}, {'itemId': 2016, 'qty': 0.1}]},
    {'id': 102, 'name': 'Taro Milk Tea', 'price': 5.50, 'ingredients': SERVING_WARE + [{'itemId': 2002, 'qty': 1.0}, {'itemId': 2004, 'qty': 0.01}, {'itemId': 2016, 'qty': 0.1}]},
    {'id': 103, 'name': 'Matcha Latte', 'price': 5.75, 'ingredients': SERVING_WARE + [{'itemId': 2003, 'qty': 0.8}, {'itemId': 2004, 'qty': 0.02}]},
    {'id': 104, 'name': 'Brown Sugar Pearl Milk', 'price': 6.00, 'ingredients': SERVING_WARE + [{'itemId': 2005, 'qty': 2.0}, {'itemId': 2006, 'qty': 0.1}, {'itemId': 2004, 'qty': 0.02}]},
    {'id': 105, 'name': 'Strawberry Smoothie', 'price': 6.25, 'ingredients': SERVING_WARE + [{'itemId': 2017, 'qty': 0.2}, {'itemId': 2004, 'qty': 0.02}]},
    {'id': 106, 'name': 'Mango Green Tea', 'price': 5.00, 'ingredients': SERVING_WARE + [{'itemId': 2015, 'qty': 0.5}, {'itemId': 2018, 'qty': 0.15}]},
    {'id': 107, 'name': 'Passion Fruit Green Tea', 'price': 5.00, 'ingredients': SERVING_WARE + [{'itemId': 2015, 'qty': 0.5}, {'itemId': 2019, 'qty': 0.15}]},
    {'id': 108, 'name': 'Oolong Milk Tea', 'price': 5.25, 'ingredients': SERVING_WARE + [{'itemId': 2007, 'qty': 0.5}, {'itemId': 2004, 'qty': 0.01}, {'itemId': 2016, 'qty': 0.1}]},
    {'id': 109, 'name': 'Caramel Macchiato', 'price': 6.50, 'ingredients': SERVING_WARE + [{'itemId': 2008, 'qty': 1.0}, {'itemId': 2004, 'qty': 0.02}, {'itemId': 2020, 'qty': 0.1}]},
    {'id': 110, 'name': 'Americano', 'price': 3.75, 'ingredients': SERVING_WARE + [{'itemId': 2008, 'qty': 0.8}]},
    {'id': 111, 'name': 'Wintermelon Tea', 'price': 4.75, 'ingredients': SERVING_WARE + [{'itemId': 2001, 'qty': 0.5}, {'itemId': 2021, 'qty': 0.1}]},
    {'id': 112, 'name': 'Thai Iced Tea', 'price': 5.50, 'ingredients': SERVING_WARE + [{'itemId': 2022, 'qty': 0.8}, {'itemId': 2004, 'qty': 0.01}, {'itemId': 2016, 'qty': 0.1}]},
    {'id': 113, 'name': 'Honeydew Milk Tea', 'price': 5.50, 'ingredients': SERVING_WARE + [{'itemId': 2023, 'qty': 1.0}, {'itemId': 2004, 'qty': 0.01}, {'itemId': 2016, 'qty': 0.1}]},
    {'id': 114, 'name': 'Lychee Black Tea', 'price': 5.00, 'ingredients': SERVING_WARE + [{'itemId': 2001, 'qty': 0.5}, {'itemId': 2024, 'qty': 0.15}]},
    {'id': 115, 'name': 'Peach Oolong Tea', 'price': 5.00, 'ingredients': SERVING_WARE + [{'itemId': 2007, 'qty': 0.5}, {'itemId': 2025, 'qty': 0.15}]},
    {'id': 116, 'name': 'Coffee Jelly Milk Tea', 'price': 6.00, 'ingredients': SERVING_WARE + [{'itemId': 2001, 'qty': 0.5}, {'itemId': 2004, 'qty': 0.01}, {'itemId': 2014, 'qty': 1.5}]}
]
MENU_POPULARITY = [0.12, 0.08, 0.07, 0.10, 0.06, 0.05, 0.05, 0.08, 0.06, 0.04, 0.05, 0.07, 0.06, 0.04, 0.04, 0.03]
FIRST_NAMES = ['John', 'Jane', 'Peter', 'Mary', 'Mike', 'Sue', 'Chris', 'Pat', 'Alex', 'Taylor']
LAST_NAMES = ['Smith', 'Doe', 'Jones', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Lee']

def write_to_csv(filename, header, data_rows):
    """Writes a list of lists to a CSV file."""
    filepath = os.path.join(OUTPUT_DIRECTORY, filename)
    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data_rows)
    print(f"  -> Wrote {len(data_rows)} rows to {filepath}")


def generate_csv_files():
    """Generates all data and writes it to separate CSV files."""
    start_time = time.time()

    if not os.path.exists(OUTPUT_DIRECTORY):
        os.makedirs(OUTPUT_DIRECTORY)

    print(f"Generating CSV files in '{OUTPUT_DIRECTORY}/'...")
   
    print("\nGenerating static data...")

    employees_data = [(i+1, random.choice(FIRST_NAMES), random.choice(LAST_NAMES), random.choice(['Manager', 'Barista'])) for i in range(NUM_EMPLOYEES)]
    write_to_csv('employees.csv', ['employeeId', 'firstName', 'lastName', 'authLevel'], employees_data)

    menu_data = [(item['id'], item['name'], item['price'], json.dumps(item['ingredients'])) for item in MENU_ITEMS]
    write_to_csv('menu.csv', ['menuItemId', 'menuItemName', 'price', 'ingredients'], menu_data)

    customers_data = []
    for i in range(NUM_CUSTOMERS):
        fname = random.choice(FIRST_NAMES)
        lname = random.choice(LAST_NAMES)
        customers_data.append((
            i+901, fname, lname,
            f"{random.randint(1995, 2005)}-{random.randint(1,12):02d}-{random.randint(1,28):02d}",
            f"979-{random.randint(100,999)}-{random.randint(1000,9999)}",
            f"{fname.lower()}.{lname.lower()}{random.randint(1,99)}@example.com",
            random.randint(0, 1000)
        ))
    write_to_csv('customerRewards.csv', ['customerId', 'firstName', 'lastName', 'DOB', 'phoneNumber', 'email', 'points'], customers_data)


    print("\nGenerating transactional data (this may take a moment)...")

    inventory_state = {item[0]: item[2] for item in INVENTORY_ITEMS}
    
    transactions_data = []
    sales_data = []
    
    total_days = (datetime.datetime.now().date() - START_DATE.date()).days + 1
    regular_days = total_days - NUM_PEAK_DAYS
    regular_day_target = TOTAL_SALES_TARGET / (regular_days + 4 * NUM_PEAK_DAYS)
    peak_day_target = 4 * regular_day_target
    
    transaction_id_counter = 1
    sale_id_counter = 1
    total_generated_sales = 0
    
    current_date = START_DATE
    while current_date.date() <= datetime.datetime.now().date():
        daily_sales = 0
        target = peak_day_target if current_date.date() == PEAK_DAY.date() else regular_day_target
        
        while daily_sales < target:
            customer_id = random.randint(901, 900 + NUM_CUSTOMERS)
            num_items_in_order = np.random.choice([1, 2, 3], p=[0.6, 0.3, 0.1])
            order_items_json = []
            
            chosen_items = np.random.choice(MENU_ITEMS, size=min(num_items_in_order, len(MENU_ITEMS)), p=MENU_POPULARITY, replace=False)
            
            transaction_value = 0
            for item_data in chosen_items:
                order_items_json.append({"menuItemId": item_data['id'], "quantity": 1})
                transaction_value += item_data['price']

                sales_data.append((sale_id_counter, item_data['name'], current_date.strftime('%B'), current_date.year, 1))
                sale_id_counter += 1

                if item_data['ingredients']:
                    for ing in item_data['ingredients']:
                        inventory_state[ing['itemId']] -= ing['qty']


            transactions_data.append((transaction_id_counter, current_date.date(), customer_id, json.dumps(order_items_json)))
            transaction_id_counter += 1
            daily_sales += transaction_value
        
        total_generated_sales += daily_sales
        if current_date.day % 10 == 0:
            print(f"  ...generated data up to {current_date.date()}")
        current_date += datetime.timedelta(days=1)

    write_to_csv('transactions.csv', ['transactionId', 'date', 'customerId', 'items'], transactions_data)
    write_to_csv('sales.csv', ['saleId', 'itemName', 'month', 'year', 'amountSold'], sales_data)

    print("\nWriting final inventory state...")
    final_inventory_data = []
    for item in INVENTORY_ITEMS:
        final_quantity = inventory_state.get(item[0], item[2])
        final_inventory_data.append((item[0], item[1], int(final_quantity)))
    write_to_csv('inventory.csv', ['itemId', 'itemName', 'quantity'], final_inventory_data)

    end_time = time.time()
    print("\n" + "="*40)
    print("✅ CSV file generation complete!")
    print(f"Total time to generate files: {end_time - start_time:.2f} seconds")
    print(f"Total transactions generated: {len(transactions_data)}")
    print(f"Total sales generated: ${total_generated_sales:,.2f}")
    print("="*40)

if __name__ == "__main__":
    try:
        generate_csv_files()
        print("\n--- Next Steps ---")
        print(f"1. A new directory '{OUTPUT_DIRECTORY}' has been created with all your CSV files.")
        print("2. Create your table schemas in your database first.")
        print("3. Use the psql '\\copy' command to import each CSV file. Example:")
        print("   \\copy inventory FROM 'path/to/your/db_population_csvs/inventory.csv' DELIMITER ',' CSV HEADER;")

    except Exception as e:
        print(f"\nAn error occurred: {e}", file=sys.stderr)

