import pandas as pd
import random
import string
from pathlib import Path
from faker import Faker
from datetime import timedelta

# =====================================================
# Configuration
# =====================================================

fake = Faker("en_IN")
random.seed(42)
Faker.seed(42)

DATA_DIR = Path(__file__).resolve().parent.parent / "datasets"

MIN_SHIPPING_COST = 40
MAX_SHIPPING_COST = 250

MIN_DISTANCE = 20
MAX_DISTANCE = 2500

# =====================================================
# Load Orders
# =====================================================

orders = pd.read_csv(DATA_DIR / "orders.csv")

orders["order_date"] = pd.to_datetime(
    orders["order_date"],
    dayfirst=True
)

# =====================================================
# Master Data
# =====================================================

courier_partners = [
    "Delhivery",
    "Blue Dart",
    "DTDC",
    "Ekart",
    "XpressBees",
    "Ecom Express"
]

delivery_modes = [
    "Standard",
    "Express",
    "Next Day",
    "Same Day"
]

delivery_mode_weights = [
    65,
    20,
    10,
    5
]

warehouses = [
    "Mumbai Warehouse",
    "Delhi Warehouse",
    "Bengaluru Warehouse",
    "Hyderabad Warehouse",
    "Chennai Warehouse",
    "Pune Warehouse",
    "Kolkata Warehouse",
    "Ahmedabad Warehouse"
]

cities = [
    "Mumbai",
    "Delhi",
    "Pune",
    "Hyderabad",
    "Bengaluru",
    "Chennai",
    "Kolkata",
    "Ahmedabad",
    "Jaipur",
    "Lucknow"
]

delay_reasons = [
    "Weather",
    "Traffic",
    "Warehouse Delay",
    "Courier Issue",
    "Customer Unavailable"
]

statuses = [
    "Delivered",
    "In Transit",
    "Delayed",
    "Returned"
]

status_weights = [
    90,
    5,
    3,
    2
]

# =====================================================
# Helper Functions
# =====================================================

used_tracking_numbers = set()


def generate_tracking_number():
    while True:
        tracking = "TRK" + "".join(
            random.choices(
                string.ascii_uppercase + string.digits,
                k=12
            )
        )

        if tracking not in used_tracking_numbers:
            used_tracking_numbers.add(tracking)
            return tracking


def generate_shipping_cost():
    return round(
        random.uniform(
            MIN_SHIPPING_COST,
            MAX_SHIPPING_COST
        ),
        2
    )


def generate_shipping_distance():
    return random.randint(
        MIN_DISTANCE,
        MAX_DISTANCE
    )


def generate_estimated_delivery(shipment_date, delivery_mode):

    if delivery_mode == "Same Day":
        return shipment_date

    elif delivery_mode == "Next Day":
        return shipment_date + timedelta(days=1)

    elif delivery_mode == "Express":
        return shipment_date + timedelta(
            days=random.randint(2, 3)
        )

    else:
        return shipment_date + timedelta(
            days=random.randint(4, 7)
        )


# =====================================================
# Generate Shipments
# =====================================================

shipments = []

for index, row in orders.iterrows():

    shipment_id = index + 1
    order_id = row["order_id"]

    courier = random.choice(courier_partners)

    delivery_mode = random.choices(
        delivery_modes,
        weights=delivery_mode_weights,
        k=1
    )[0]

    shipment_date = row["order_date"] + timedelta(
        days=random.randint(0, 2),
        hours=random.randint(0, 12)
    )

    estimated_delivery = generate_estimated_delivery(
        shipment_date,
        delivery_mode
    )

    status = random.choices(
        statuses,
        weights=status_weights,
        k=1
    )[0]

    shipping_cost = generate_shipping_cost()

    warehouse = random.choice(warehouses)

    city = random.choice(cities)

    distance = generate_shipping_distance()

    tracking = generate_tracking_number()

    # =====================================================
    # Delivery Logic
    # =====================================================

    actual_delivery = None
    delivery_attempts = 0
    delivery_rating = None
    on_time_delivery = None
    delay_reason = None

    if status == "Delivered":

        actual_delivery = estimated_delivery + timedelta(
            days=random.choice([-1, 0, 0, 0, 1])
        )

        delivery_attempts = random.choices(
            [1, 2, 3],
            weights=[88, 10, 2],
            k=1
        )[0]

        delivery_rating = random.choices(
            [5, 4, 3, 2, 1],
            weights=[60, 25, 10, 3, 2],
            k=1
        )[0]

        on_time_delivery = (
            actual_delivery.date()
            <= estimated_delivery.date()
        )

    elif status == "Delayed":

        actual_delivery = estimated_delivery + timedelta(
            days=random.randint(2, 5)
        )

        delivery_attempts = random.choices(
            [1, 2, 3],
            weights=[55, 30, 15],
            k=1
        )[0]

        delivery_rating = random.choices(
            [5, 4, 3, 2, 1],
            weights=[8, 15, 35, 27, 15],
            k=1
        )[0]

        on_time_delivery = False

        delay_reason = random.choice(delay_reasons)

    elif status == "Returned":

        actual_delivery = estimated_delivery + timedelta(
            days=random.randint(0, 2)
        )

        delivery_attempts = random.randint(1, 3)

        delivery_rating = random.choice([1, 2, 3])

    else:   # In Transit

        delivery_attempts = 0

    shipments.append({

        "shipment_id": shipment_id,
        "order_id": order_id,
        "courier_partner": courier,
        "delivery_mode": delivery_mode,
        "shipment_date": shipment_date,
        "estimated_delivery_date": estimated_delivery.date(),
        "actual_delivery_date": (
            actual_delivery.date()
            if actual_delivery
            else None
        ),
        "delivery_status": status,
        "tracking_number": tracking,
        "shipping_cost": shipping_cost,
        "shipping_distance_km": distance,
        "warehouse_location": warehouse,
        "delivery_city": city,
        "delivery_attempts": delivery_attempts,
        "delivery_rating": delivery_rating,
        "on_time_delivery": on_time_delivery,
        "delay_reason": delay_reason

    })

# =====================================================
# Create DataFrame
# =====================================================

shipments_df = pd.DataFrame(shipments)

shipments_df.sort_values(
    by="shipment_id",
    inplace=True
)

shipments_df.to_csv(
    DATA_DIR / "shipments.csv",
    index=False
)

print("\n" + "=" * 50)
print("✅ Shipments dataset generated successfully!")
print("=" * 50)
print(f"Total Shipments : {len(shipments_df):,}")
print(f"File Saved To   : {DATA_DIR / 'shipments.csv'}")
print("=" * 50)