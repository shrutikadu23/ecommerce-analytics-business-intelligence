from faker import Faker
import pandas as pd
import random
from datetime import datetime, timedelta

# -------------------------------------------------
# FAKER
# -------------------------------------------------

fake = Faker("en_IN")

random.seed(42)
Faker.seed(42)

# -------------------------------------------------
# LOAD DATASETS
# -------------------------------------------------

customers = pd.read_csv("../datasets/customers.csv")
addresses = pd.read_csv("../datasets/addresses.csv")

# -------------------------------------------------
# CONFIGURATION
# -------------------------------------------------

TOTAL_ORDERS = 25000

TODAY = datetime.today()

START_DATE = datetime(2023, 1, 1)

ORDER_STATUSES = [
    "Delivered",
    "Shipped",
    "Confirmed",
    "Pending",
    "Cancelled",
    "Returned"
]

ORDER_STATUS_WEIGHTS = [
    80,
    8,
    5,
    4,
    2,
    1
]

ORDER_SOURCES = [
    "Website",
    "Mobile App"
]

ORDER_SOURCE_WEIGHTS = [
    60,
    40
]

# -------------------------------------------------
# HELPER FUNCTIONS
# -------------------------------------------------

def generate_order_date():

    r = random.random()

    if r < 0.15:
        start = datetime(2023, 1, 1)
        end = datetime(2023, 12, 31)

    elif r < 0.45:
        start = datetime(2024, 1, 1)
        end = datetime(2024, 12, 31)

    elif r < 0.75:
        start = datetime(2025, 1, 1)
        end = datetime(2025, 12, 31)

    else:
        start = datetime(2026, 1, 1)
        end = TODAY

    random_days = random.randint(0, (end - start).days)

    return (start + timedelta(days=random_days)).date()


def generate_order_status():

    return random.choices(
        ORDER_STATUSES,
        weights=ORDER_STATUS_WEIGHTS,
        k=1
    )[0]


def generate_order_source():

    return random.choices(
        ORDER_SOURCES,
        weights=ORDER_SOURCE_WEIGHTS,
        k=1
    )[0]


def generate_expected_delivery(order_date, order_status):

    if order_status == "Cancelled":
        return order_date + timedelta(days=random.randint(2, 7))

    elif order_status == "Pending":
        return order_date + timedelta(days=random.randint(4, 8))

    elif order_status == "Confirmed":
        return order_date + timedelta(days=random.randint(3, 7))

    elif order_status == "Shipped":
        return order_date + timedelta(days=random.randint(2, 5))

    elif order_status == "Delivered":
        return order_date + timedelta(days=random.randint(2, 7))

    else:      # Returned
        return order_date + timedelta(days=random.randint(2, 7))


# -------------------------------------------------
# CUSTOMER → ADDRESS MAPPING
# -------------------------------------------------

customer_address_map = {}

for _, row in addresses.iterrows():

    customer_id = row["customer_id"]
    address_id = row["address_id"]

    if customer_id not in customer_address_map:
        customer_address_map[customer_id] = []

    customer_address_map[customer_id].append(address_id)

# -------------------------------------------------
# READY TO GENERATE ORDERS
# -------------------------------------------------

orders = []

# -------------------------------------------------
# GENERATE ORDERS
# -------------------------------------------------

for _ in range(TOTAL_ORDERS):

    customer_id = random.choices(
        population=customers["customer_id"],
        weights=customers["is_active"].map(
            lambda x: 5 if x else 1
    ),
    k=1
)[0]

    # Select one of the customer's addresses
    address_id = random.choice(
        customer_address_map[customer_id]
    )

    # Order Date
    order_date = generate_order_date()

    # Status
    order_status = generate_order_status()

    # Expected Delivery
    expected_delivery_date = generate_expected_delivery(
        order_date,
        order_status
    )

    # -------------------------------------------------
    # TEMPORARY ORDER VALUE
    # -------------------------------------------------

    amount_range = random.choices( 

    [
        (199, 999),
        (1000, 2999),
        (3000, 7999),
        (8000, 15000),
        (15000, 35000)

    ],

    weights=[35,35,20,8,2],

    k=1

)[0]

    total_amount = round(
        random.uniform(
            amount_range[0],
            amount_range[1]
        ),
        2
    )

    # Coupon Discount

    coupon_discount = random.choices(

        [0,5,10,20],

        weights=[70,15,10,5],

        k=1

    )[0]

    # Order Source  
        
    order_source = generate_order_source()

    orders.append({

            "customer_id": customer_id,

            "address_id": address_id,

            "order_date": order_date,

            "order_status": order_status,

            "total_amount": total_amount,

            "coupon_discount": coupon_discount,

            "order_source": order_source,

            "expected_delivery_date": expected_delivery_date

        })

# -------------------------------------------------
# DATAFRAME
# -------------------------------------------------
orders_df = pd.DataFrame(orders)

orders_df = orders_df.sort_values(
    by=["order_date", "customer_id"]
).reset_index(drop=True)


# -------------------------------------------------
# SORT ORDERS BY DATE
# -------------------------------------------------

orders_df.insert(
    0,
    "order_id",
    range(1, len(orders_df) + 1)
)

# -------------------------------------------------
# EXPORT CSV
# -------------------------------------------------

orders_df.to_csv(
    "../datasets/orders.csv",
    index=False
)

# -------------------------------------------------
# SUMMARY
# -------------------------------------------------

print("=" * 60)
print("Orders Dataset Validation")
print("=" * 60)
print(f"Total Orders          : {len(orders_df):,}")
print(f"Duplicate Order IDs   : {orders_df['order_id'].duplicated().sum()}")
print(f"Unique Customers      : {orders_df['customer_id'].nunique():,}")
print("=" * 60)

print("\nOrder Status Distribution")
print(orders_df["order_status"].value_counts())

print("\nOrder Source Distribution")
print(orders_df["order_source"].value_counts())

print(f"\nAverage Order Value : ₹{orders_df['total_amount'].mean():,.2f}")

print(f"Average Coupon (%)  : {orders_df['coupon_discount'].mean():.2f}")

print("\n✅ orders.csv generated successfully!")