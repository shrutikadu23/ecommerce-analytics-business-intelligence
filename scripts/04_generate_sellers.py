from faker import Faker
import pandas as pd
import random
from datetime import datetime, timedelta

from config import (
    STATE_CITY_MAP,
    SELLER_PREFIXES,
    SELLER_SUFFIXES
)

fake = Faker("en_IN")

random.seed(42)
Faker.seed(42)

# ---------------------------------------
# UNIQUE SELLER NAMES
# ---------------------------------------

used_names = set()
used_emails = set()
used_phones = set()


def generate_seller_name():
    while True:
        name = f"{random.choice(SELLER_PREFIXES)}{random.choice(SELLER_SUFFIXES)}"

        if name not in used_names:
            used_names.add(name)
            return name


# ---------------------------------------
# REGISTRATION DATE
# ---------------------------------------

def generate_registration_date():

    r = random.random()

    if r < 0.05:
        start = datetime(2015, 1, 1)
        end = datetime(2017, 12, 31)

    elif r < 0.25:
        start = datetime(2018, 1, 1)
        end = datetime(2020, 12, 31)

    elif r < 0.70:
        start = datetime(2021, 1, 1)
        end = datetime(2023, 12, 31)

    else:
        start = datetime(2024, 1, 1)
        end = datetime(2026, 6, 30)

    random_days = random.randint(0, (end - start).days)

    return (start + timedelta(days=random_days)).date()


# ---------------------------------------
# SELLER RATING
# ---------------------------------------

def generate_rating():

    r = random.random()

    if r < 0.40:
        return round(random.uniform(4.5, 5.0), 1)

    elif r < 0.75:
        return round(random.uniform(4.0, 4.4), 1)

    elif r < 0.90:
        return round(random.uniform(3.5, 3.9), 1)

    elif r < 0.97:
        return round(random.uniform(3.0, 3.4), 1)

    else:
        return round(random.uniform(2.0, 2.9), 1)


# ---------------------------------------
# SELLER STATUS
# ---------------------------------------

def generate_status():

    return random.choices(

        population=[
            "Active",
            "Inactive",
            "Suspended"
        ],

        weights=[
            90,
            8,
            2
        ],

        k=1

    )[0]


# ---------------------------------------
# VERIFIED
# ---------------------------------------

def generate_verified():

    return random.choices(

        [True, False],

        weights=[80, 20],

        k=1

    )[0]

# ---------------------------------------
# GENERATE SELLERS
# ---------------------------------------

sellers = []

for _ in range(500):

    # Seller Name
    seller_name = generate_seller_name()

        # Email
    while True:
        domain = seller_name.lower().replace(" ", "")

        prefix = random.choice([
            "contact",
            "sales",
            "support",
            "info",
            "hello"
        ])

        seller_email = f"{prefix}@{domain}.com"

        if seller_email not in used_emails:
            used_emails.add(seller_email)
            break

    # Phone
    while True:
        seller_phone = f"9{random.randint(100000000, 999999999)}"

        if seller_phone not in used_phones:
            used_phones.add(seller_phone)
            break

    # State & City
    state = random.choice(list(STATE_CITY_MAP.keys()))
    city = random.choice(STATE_CITY_MAP[state])

    # Category Specialization
    specialization_category_id = random.randint(1, 10)

    # Registration Date
    registration_date = generate_registration_date()

    # Rating
    seller_rating = generate_rating()

    # Status
    seller_status = generate_status()

    # Verified
    is_verified = generate_verified()

    sellers.append({
        
        "seller_id": len(sellers) + 1,
        "seller_name": seller_name,
        "seller_email": seller_email,
        "seller_phone": seller_phone,
        "city": city,
        "state": state,
        "specialization_category_id": specialization_category_id,
        "registration_date": registration_date,
        "seller_rating": seller_rating,
        "seller_status": seller_status,
        "is_verified": is_verified

    })
# ---------------------------------------
# DATAFRAME
# ---------------------------------------

df = pd.DataFrame(sellers)

# ---------------------------------------
# DATA VALIDATION
# ---------------------------------------

print("=" * 60)
print("Seller Dataset Validation")
print("=" * 60)
print(f"Total Sellers      : {len(df)}")
print(f"Duplicate Names    : {df['seller_name'].duplicated().sum()}")
print(f"Duplicate Emails   : {df['seller_email'].duplicated().sum()}")
print(f"Duplicate Phones   : {df['seller_phone'].duplicated().sum()}")
print("=" * 60)

# ---------------------------------------
# SAVE CSV
# ---------------------------------------

df.to_csv(
    "../datasets/sellers.csv",
    index=False
)

print("\n✅ sellers.csv generated successfully!")


        