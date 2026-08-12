from faker import Faker
import pandas as pd
import random

# ----------------------------
# Configuration
# ----------------------------

fake = Faker("en_IN")

random.seed(42)
Faker.seed(42)

NUM_CUSTOMERS = 10000

customers = []

# ----------------------------
# Generate Customers
# ----------------------------

for customer_id in range(1, NUM_CUSTOMERS + 1):

    customers.append({
        "customer_id": customer_id,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "email": fake.unique.email(),
        "phone": fake.unique.numerify("9#########"),
        "join_date": fake.date_between(
            start_date="-5y",
            end_date="today"
        ),
        "is_active": random.choice([True, False])
    })

# ----------------------------
# Create DataFrame
# ----------------------------

df = pd.DataFrame(customers)

# ----------------------------
# Data Validation
# ----------------------------

duplicate_emails = df["email"].duplicated().sum()
duplicate_phones = df["phone"].duplicated().sum()

print("=" * 60)
print("Customer Dataset Validation")
print("=" * 60)
print(f"Total Customers   : {len(df):,}")
print(f"Duplicate Emails  : {duplicate_emails}")
print(f"Duplicate Phones  : {duplicate_phones}")
print("=" * 60)

# ----------------------------
# Save CSV
# ----------------------------

df.to_csv("../datasets/customers.csv", index=False)

print("\ncustomers.csv generated successfully!")