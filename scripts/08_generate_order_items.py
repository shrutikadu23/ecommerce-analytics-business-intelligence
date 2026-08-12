import random
from pathlib import Path

import pandas as pd

# ======================================================
# Configuration
# ======================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_FOLDER = BASE_DIR / "datasets"

ORDERS_FILE = DATA_FOLDER / "orders.csv"
PRODUCTS_FILE = DATA_FOLDER / "products.csv"

random.seed(42)

pd.options.display.float_format = '{:.2f}'.format

# ======================================================
# Load Data
# ======================================================

orders_df = pd.read_csv(ORDERS_FILE)
products_df = pd.read_csv(PRODUCTS_FILE)

TOTAL_ORDERS = len(orders_df)

print(f"Orders Loaded : {TOTAL_ORDERS}")
print(f"Products Loaded : {len(products_df)}")

# ======================================================
# Product Lookup
# ======================================================

products_lookup = {}

for _, row in products_df.iterrows():
    products_lookup[row["product_id"]] = {
        "price": row["price"]
    }

product_ids = list(products_lookup.keys())

# ======================================================
# Generate Order Items
# ======================================================

# Create order items
order_items = []

for order_id in range(1, TOTAL_ORDERS + 1):

    # Each order will have 1–5 products
    num_items = random.randint(1, 3)

    # Choose unique products
    selected_products = random.sample(product_ids, num_items)

    for product_id in selected_products:

        if product_id not in products_lookup:
           continue


        product = products_lookup[product_id]

        quantity = random.randint(1, 3)

        unit_price = round(float(product["price"]), 2)

        discount = random.choices(
            [0, 5, 10, 15, 20],
            weights=[45, 25, 15, 10, 5],
            k=1
        )[0]

        discount_amount = round(
            quantity * unit_price * discount / 100,
            2
        )

        order_items.append({
            "order_id": order_id,
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": unit_price,
            "discount_amount": discount_amount
        })

print(f"Generated {len(order_items)} order items.")

# Save CSV
output_file = DATA_FOLDER / "order_items.csv"

order_items_df = pd.DataFrame(order_items)

order_items_df.sort_values(
    ["order_id", "product_id"],
    inplace=True
)

order_items_df.to_csv(
    output_file,
    index=False
)

print(f"Saved to {output_file}")

print(f"Total Orders      : {TOTAL_ORDERS}")
print(f"Total Order Items : {len(order_items)}")
print(f"Average Items/Order : {len(order_items) / TOTAL_ORDERS:.2f}")