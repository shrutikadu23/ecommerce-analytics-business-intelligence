import random
from datetime import datetime, timedelta

import pandas as pd

random.seed(42)

TODAY = datetime.today()

# ----------------------------------------
# LOAD PRODUCTS
# ----------------------------------------

products = pd.read_csv("../datasets/products.csv")

# ----------------------------------------
# CATEGORY STOCK RANGES
# ----------------------------------------

CATEGORY_STOCK = {

    1: (5, 80),        # Electronics
    2: (40, 300),      # Fashion
    3: (20, 180),      # Home & Kitchen
    4: (15, 200),      # Books
    5: (25, 150),      # Beauty
    6: (10, 120),      # Sports
    7: (20, 150),      # Toys
    8: (100, 500),     # Grocery
    9: (20, 120),      # Health
    10: (5, 100)       # Automotive

}

inventory = []

inventory_id = 1

# ----------------------------------------
# GENERATE INVENTORY
# ----------------------------------------

for _, product in products.iterrows():

    category_id = product["category_id"]

    minimum_stock, maximum_stock = CATEGORY_STOCK[category_id]

    # Mostly healthy stock, some low stock, few out of stock

    r = random.random()

    if r < 0.03:

        stock_quantity = 0

    elif r < 0.15:

        stock_quantity = random.randint(1, 10)

    else:

        stock_quantity = random.randint(
            minimum_stock,
            maximum_stock
        )

    reorder_level = random.choices(
         population=[10, 15, 20, 25, 30],
         weights=[35, 30, 20, 10, 5],
         k=1
    )[0]

    r = random.random()

    if r < 0.60:
        days = random.randint(1, 30)
    elif r < 0.90:
        days = random.randint(31, 90)
    else:
        days = random.randint(91, 180)

    last_restock_date = (TODAY - timedelta(days=days)).date()

    inventory.append({

        "inventory_id": inventory_id,

        "product_id": product["product_id"],

        "stock_quantity": stock_quantity,

        "reorder_level": reorder_level,

        "last_restock_date": last_restock_date

    })

    inventory_id += 1

# ----------------------------------------
# DATAFRAME
# ----------------------------------------

inventory_df = pd.DataFrame(inventory)

# ----------------------------------------
# EXPORT CSV
# ----------------------------------------

inventory_df.to_csv(

    "../datasets/inventory.csv",

    index=False

)

print("=" * 60)
print("Inventory Dataset Validation")
print("=" * 60)
print(f"Total Inventory Records : {len(inventory_df):,}")
print(f"Duplicate Inventory IDs : {inventory_df['inventory_id'].duplicated().sum()}")
print(f"Duplicate Product IDs   : {inventory_df['product_id'].duplicated().sum()}")
print("=" * 60)

print("\nInventory Status")
print(f"Out of Stock : {(inventory_df['stock_quantity'] == 0).sum()}")
print(f"Low Stock    : {((inventory_df['stock_quantity'] > 0) & (inventory_df['stock_quantity'] <= 10)).sum()}")
print(f"In Stock     : {(inventory_df['stock_quantity'] > 10).sum()}")

print("\n✅ inventory.csv generated successfully!")