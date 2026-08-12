from faker import Faker
import pandas as pd
import random
from datetime import datetime, timedelta

fake = Faker("en_IN")

random.seed(42)
Faker.seed(42)

# -----------------------------
# LOAD SELLERS
# -----------------------------

sellers = pd.read_csv("../datasets/sellers.csv")

# -----------------------------
# CATEGORY INFORMATION
# -----------------------------

CATEGORY_DATA = {

    1: {
        "name": "Electronics",
        "brands": ["Samsung","Apple","Dell","HP","Lenovo","Sony","LG","Asus"],
        "products": ["Laptop","Smartphone","Tablet","Smart Watch","Headphones","Monitor","Keyboard","Mouse"],
        "price_range": (2000,150000),
        "sku": "ELE"
    },

    2: {
        "name": "Fashion",
        "brands": ["Nike","Adidas","Puma","Levis","Allen Solly","Zara","H&M"],
        "products": ["T-Shirt","Jeans","Sneakers","Jacket","Dress","Shirt","Hoodie"],
        "price_range": (300,8000),
        "sku": "FAS"
    },

    3: {
        "name": "Home & Kitchen",
        "brands": ["Prestige","Philips","Milton","Pigeon","Borosil","Cello"],
        "products": ["Mixer","Cookware Set","Bottle","Pressure Cooker","Induction Cooktop","Storage Box"],
        "price_range": (500,25000),
        "sku": "HMK"
    },

    4: {
        "name": "Books",
        "brands": ["Penguin","HarperCollins","Oxford","McGraw Hill","Pearson"],
        "products": ["Novel","Dictionary","Textbook","Story Book","Biography"],
        "price_range": (150,2000),
        "sku": "BOO"
    },

    5: {
        "name": "Beauty",
        "brands": ["Lakme","Maybelline","Nivea","Loreal","Mamaearth","Minimalist"],
        "products": ["Face Wash","Shampoo","Serum","Lipstick","Moisturizer","Sunscreen"],
        "price_range": (150,5000),
        "sku": "BEA"
    },

    6: {
        "name": "Sports",
        "brands": ["Nike","Adidas","Puma","Yonex","Cosco","SG"],
        "products": ["Football","Cricket Bat","Yoga Mat","Dumbbells","Badminton Racket"],
        "price_range": (500,30000),
        "sku": "SPO"
    },

    7: {
        "name": "Toys",
        "brands": ["Lego","Funskool","Hot Wheels","Barbie","Nerf"],
        "products": ["Puzzle","Toy Car","Building Blocks","Doll","Board Game"],
        "price_range": (200,5000),
        "sku": "TOY"
    },

    8: {
        "name": "Grocery",
        "brands": ["Tata","Fortune","Aashirvaad","Amul","Nestle"],
        "products": ["Rice","Atta","Oil","Tea","Coffee","Milk Powder"],
        "price_range": (50,2000),
        "sku": "GRO"
    },

    9: {
        "name": "Health",
        "brands": ["Himalaya","Dabur","Horlicks","Ensure","Dettol"],
        "products": ["Protein Powder","Vitamin Tablets","Hand Sanitizer","First Aid Kit"],
        "price_range": (100,5000),
        "sku": "HEA"
    },

    10: {
        "name": "Automotive",
        "brands": ["Bosch","Castrol","3M","Michelin","GoMechanic"],
        "products": ["Engine Oil","Helmet","Car Cover","Tyre Inflator","Cleaning Kit"],
        "price_range": (500,50000),
        "sku": "AUT"
    }

}

# -----------------------------
# HELPER FUNCTIONS
# -----------------------------

sku_counter = 1

def generate_sku(category_code, brand):

    global sku_counter

    sku = f"{category_code}-{brand[:3].upper()}-{sku_counter:05d}"

    sku_counter += 1

    return sku


def generate_launch_date():

    r = random.random()

    if r < 0.10:
        start = datetime(2018, 1, 1)
        end = datetime(2019, 12, 31)

    elif r < 0.35:
        start = datetime(2020, 1, 1)
        end = datetime(2022, 12, 31)

    else:
        start = datetime(2023, 1, 1)
        end = datetime(2026, 6, 30)

    random_days = random.randint(0, (end - start).days)

    return (start + timedelta(days=random_days)).date()

def generate_discount():

    return random.choices(
     population=[0,5,10,15,20,25,30,40,50],
     weights=[20,20,18,15,10,7,5,3,2],
     k=1
)[0]


def generate_rating():

    return random.choices(

        population=[5.0,4.9,4.8,4.7,4.6,4.5,4.4,4.3,4.2,4.1,4.0,3.9,3.8,3.7,3.6,3.5],

        weights=[10,10,10,9,9,8,7,6,5,4,4,3,2,2,1,1],

        k=1

    )[0]

# -----------------------------
# GENERATE PRODUCTS
# -----------------------------

products = []

product_id = 1

for index, seller in sellers.iterrows():

    seller_id = index + 1
    category_id = seller["specialization_category_id"]

    category = CATEGORY_DATA[category_id]

    number_of_products = random.choices(
       population=[2,3,4,5,6,7,8],
       weights=[5,10,20,30,20,10,5],
       k=1
    )[0]

    for _ in range(number_of_products):

        brand = random.choice(category["brands"])

        product_type = random.choice(category["products"])

        adjective = random.choice([
            "Premium",
            "Classic",
            "Ultra",
            "Smart",
            "Pro",
            "Max",
            "Elite",
            "Advanced",
            "Eco",
            "Plus"
        ])

        product_name = f"{brand} {adjective} {product_type}"

        min_price, max_price = category["price_range"]

        price = round(random.uniform(min_price, max_price),2)

        cost_price = round(price * random.uniform(0.55,0.85),2)

        discount = generate_discount()

        rating = generate_rating()

        launch_date = generate_launch_date()

        years_old = max(0, datetime.now().year - launch_date.year)

        total_reviews = random.randint(
            years_old * 20,
            years_old * 120 + 50
        )

        sku = generate_sku(
            category["sku"],
            brand
        )

        description = (
            f"{brand} {product_type} designed for "
            f"quality, durability and everyday use."
        )

        is_active = random.choices(
            [True,False],
            weights=[97,3],
            k=1
        )[0]

        products.append({

            "product_id": product_id,
            "product_name": product_name,
            "category_id": category_id,
            "seller_id": seller_id,
            "brand": brand,
            "stock_keeping_unit": sku,
            "price": price,
            "cost_price": cost_price,
            "discount_percentage": discount,
            "description": description,
            "average_rating": rating,
            "total_reviews": total_reviews,
            "launch_date": launch_date,
            "is_active": is_active

        })

        product_id += 1

# -----------------------------
# DATAFRAME
# -----------------------------

df = pd.DataFrame(products)

# -----------------------------
# SAVE CSV
# -----------------------------

print("=" * 60)
print("Product Dataset Validation")
print("=" * 60)
print(f"Total Products      : {len(df):,}")
print(f"Unique SKUs         : {df['stock_keeping_unit'].nunique():,}")
print(f"Duplicate SKUs      : {df['stock_keeping_unit'].duplicated().sum()}")
print(f"Duplicate ProductID : {df['product_id'].duplicated().sum()}")
print(f"Duplicate Names     : {df['product_name'].duplicated().sum()}")
print("=" * 60)

df.to_csv(
    "../datasets/products.csv",
    index=False
)

print("\nProducts by Category")
print(df["category_id"].value_counts().sort_index())

print("\nProduct Status")
print(df["is_active"].value_counts())

print(f"\n✅ products.csv generated successfully!")

