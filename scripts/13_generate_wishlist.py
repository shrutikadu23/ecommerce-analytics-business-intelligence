import pandas as pd
import random
from faker import Faker
from datetime import datetime

# ----------------------------
# Configuration
# ----------------------------

NUM_CUSTOMERS = 10000
NUM_PRODUCTS = 2552

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATASET_DIR = BASE_DIR / "datasets"

OUTPUT_FILE = DATASET_DIR / "wishlist.csv"

random.seed(42)
Faker.seed(42)
fake = Faker("en_IN")

TODAY = datetime.today()

# ----------------------------
# Product popularity
# ----------------------------

# Lower product IDs are assumed to be slightly more popular.
product_weights = [1 / ((i + 1) ** 0.35) for i in range(NUM_PRODUCTS)]

# ----------------------------
# Helper Functions
# ----------------------------

def wishlist_size():
    r = random.random()

    if r < 0.60:
        return random.randint(0, 2)

    elif r < 0.85:
        return random.randint(3, 5)

    elif r < 0.95:
        return random.randint(6, 10)

    else:
        return random.randint(11, 20)


def moved_probability(days_old):

    if days_old < 30:
        return 0.08

    elif days_old < 180:
        return 0.20

    elif days_old < 365:
        return 0.30

    else:
        return 0.40


# ----------------------------
# Generate Wishlist
# ----------------------------

records = []

for customer_id in range(1, NUM_CUSTOMERS + 1):

    items = wishlist_size()

    if items == 0:
        continue

    chosen_products = random.choices(
        population=range(1, NUM_PRODUCTS + 1),
        weights=product_weights,
        k=items * 2
    )

    chosen_products = list(dict.fromkeys(chosen_products))[:items]

    while len(chosen_products) < items:

        p = random.choices(
            population=range(1, NUM_PRODUCTS + 1),
            weights=product_weights,
            k=1
        )[0]

        if p not in chosen_products:
            chosen_products.append(p)

    for product_id in chosen_products:

        added_date = fake.date_time_between(
            start_date="-3y",
            end_date="now"
        )

        age_days = (TODAY - added_date).days

        records.append({

            "customer_id": customer_id,

            "product_id": product_id,

            "added_date": added_date,

            "moved_to_cart": random.random() < moved_probability(age_days)

        })

# ----------------------------
# Save CSV
# ----------------------------

wishlist = pd.DataFrame(records)

wishlist = wishlist.sample(
    frac=1,
    random_state=42
).reset_index(drop=True)

wishlist.to_csv(
    OUTPUT_FILE,
    index=False
)

print("=" * 60)
print("Wishlist dataset generated successfully!")
print(f"Total Records : {len(wishlist):,}")
print(f"Customers     : {wishlist['customer_id'].nunique():,}")
print(f"Products Used : {wishlist['product_id'].nunique():,}")
print("=" * 60)