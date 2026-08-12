from faker import Faker
import pandas as pd
import random

fake = Faker("en_IN")

random.seed(42)
Faker.seed(42)

addresses = []
address_id = 1

ADDRESS_TYPES = ["Home", "Office", "Other"]
ADDRESS_WEIGHTS = [75, 20, 5]

for customer_id in range(1, 10001):

    # Each customer gets 1 to 3 addresses
    num_addresses = random.choices(
        population=[1, 2, 3],
        weights=[70, 25, 5],
        k=1
)[0]

    for _ in range(num_addresses):

        addresses.append({
            "address_id": address_id,
            "customer_id": customer_id,
            "address_line": fake.street_address(),
            "city": fake.city(),
            "state": fake.state(),
            "postal_code": fake.postcode(),
            "country": "India",
            "address_type": random.choices(
        population=ADDRESS_TYPES,
        weights=ADDRESS_WEIGHTS,
        k=1
)[0]
        })

        address_id += 1

df = pd.DataFrame(addresses)

print("=" * 60)
print("Address Dataset Validation")
print("=" * 60)
print(f"Total Addresses       : {len(df):,}")
print(f"Unique Customers      : {df['customer_id'].nunique():,}")
print(f"Duplicate Address IDs : {df['address_id'].duplicated().sum()}")
print("=" * 60)

print("\nAddress Type Distribution")
print(df["address_type"].value_counts())

df.to_csv("../datasets/addresses.csv", index=False)

print("\n✅ addresses.csv generated successfully!")
