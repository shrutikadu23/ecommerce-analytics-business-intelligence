import pandas as pd
import random
from pathlib import Path
from faker import Faker


# =====================================================
# Configuration
# =====================================================

fake = Faker("en_IN")

random.seed(42)
Faker.seed(42)

DATA_DIR = Path(__file__).resolve().parent.parent / "datasets"

REVIEW_PROBABILITY = 0.75

MIN_HELPFUL_VOTES = 0
MAX_HELPFUL_VOTES = 100


# =====================================================
# Load Required Datasets
# =====================================================

order_items = pd.read_csv(
    DATA_DIR / "order_items.csv"
)

# =====================================================
# Create Order Item ID
# =====================================================

order_items.insert(
    0,
    "order_item_id",
    range(1, len(order_items) + 1)
)

orders = pd.read_csv(
    DATA_DIR / "orders.csv"
)

products = pd.read_csv(
    DATA_DIR / "products.csv"
)

customers = pd.read_csv(
    DATA_DIR / "customers.csv"
)

sellers = pd.read_csv(
    DATA_DIR / "sellers.csv"
)

shipments = pd.read_csv(
    DATA_DIR / "shipments.csv"
)


# =====================================================
# Date Conversion
# =====================================================

orders["order_date"] = pd.to_datetime(
    orders["order_date"],
    dayfirst=True
)

shipments["actual_delivery_date"] = pd.to_datetime(
    shipments["actual_delivery_date"],
    dayfirst=True,
    errors="coerce"
)


# =====================================================
# Filter Delivered Orders Only
# =====================================================

delivered_shipments = shipments[
    shipments["delivery_status"] == "Delivered"
]


# =====================================================
# Connect Orders With Delivery
# =====================================================

delivered_orders = orders.merge(
    delivered_shipments[
        [
            "order_id",
            "actual_delivery_date"
        ]
    ],
    on="order_id",
    how="inner"
)


# =====================================================
# Connect Order Items
# =====================================================

review_base = order_items.merge(
    delivered_orders[
        [
            "order_id",
            "customer_id",
            "actual_delivery_date"
        ]
    ],
    on="order_id",
    how="inner"
)


# =====================================================
# Connect Products and Sellers
# =====================================================

review_base = review_base.merge(
    products[
        [
            "product_id",
            "seller_id"
        ]
    ],
    on="product_id",
    how="inner"
)


print(
    f"Eligible Delivered Items: {len(review_base):,}"
)


# =====================================================
# Review Content Templates
# =====================================================

review_titles = {

    5: [
        "Excellent Product",
        "Worth Every Penny",
        "Amazing Quality",
        "Highly Recommended",
        "Loved It"
    ],

    4: [
        "Very Good",
        "Good Value",
        "Satisfied",
        "Nice Purchase"
    ],

    3: [
        "Average Product",
        "Okay Overall",
        "Meets Expectations"
    ],

    2: [
        "Could Be Better",
        "Quality Issues",
        "Not As Expected"
    ],

    1: [
        "Very Disappointed",
        "Poor Quality",
        "Waste of Money"
    ]
}


review_texts = {

    5: [
        "Excellent quality and great experience.",
        "Product works perfectly. Really satisfied.",
        "Amazing purchase. Highly recommended."
    ],

    4: [
        "Good product with decent quality.",
        "Happy with the purchase.",
        "Value for money."
    ],

    3: [
        "Product is okay but can improve.",
        "Average experience overall."
    ],

    2: [
        "Quality was below expectations.",
        "Not very satisfied with the product."
    ],

    1: [
        "Very poor quality.",
        "Disappointed with this purchase."
    ]

}


# =====================================================
# Rating Distribution
# =====================================================

ratings = [
    5,
    4,
    3,
    2,
    1
]

rating_weights = [
    55,
    25,
    12,
    6,
    2
]


# =====================================================
# Sentiment Mapping
# =====================================================

sentiment_map = {

    5: "Positive",
    4: "Positive",
    3: "Neutral",
    2: "Negative",
    1: "Negative"

}


# =====================================================
# Review Sources
# =====================================================

review_sources = [
    "Website",
    "Mobile App",
    "Email Campaign"
]

review_source_weights = [
    50,
    40,
    10
]


# =====================================================
# Review Status
# =====================================================

review_statuses = [
    "Approved",
    "Pending",
    "Rejected"
]

review_status_weights = [
    95,
    4,
    1
]

# =====================================================
# Generate Reviews
# =====================================================

reviews = []

review_id = 1


for _, row in review_base.iterrows():

    # Customers do not always leave reviews
    if random.random() > REVIEW_PROBABILITY:
        continue


    rating = random.choices(
        ratings,
        weights=rating_weights,
        k=1
    )[0]


    review_date = (
        pd.to_datetime(
            row["actual_delivery_date"]
        )
        +
        pd.Timedelta(
            days=random.randint(1, 30)
        )
    )


    helpful_votes = random.choices(
        range(
            MIN_HELPFUL_VOTES,
            MAX_HELPFUL_VOTES + 1
        ),
        weights=[
            max(
                1,
                100 - i
            )
            for i in range(
                MIN_HELPFUL_VOTES,
                MAX_HELPFUL_VOTES + 1
            )
        ],
        k=1
    )[0]


    has_review_images = random.choices(
        [True, False],
        weights=[25, 75],
        k=1
    )[0]


    review_source = random.choices(
        review_sources,
        weights=review_source_weights,
        k=1
    )[0]


    review_status = random.choices(
        review_statuses,
        weights=review_status_weights,
        k=1
    )[0]


    seller_response_status = "Pending"

    seller_response = None


    # Low ratings are more likely to get seller responses
    if rating <= 2:

        seller_response_status = random.choices(
            [
                "Responded",
                "Pending"
            ],
            weights=[
                70,
                30
            ],
            k=1
        )[0]


        if seller_response_status == "Responded":

            seller_response = random.choice(
                [
                    "We are sorry for the inconvenience. We will improve our service.",
                    "Thank you for your feedback. We are working to improve quality.",
                    "We apologize for the experience and appreciate your feedback."
                ]
            )


    reviews.append({

        "review_id": review_id,

        "order_item_id":
            row["order_item_id"],

        "customer_id":
            row["customer_id"],

        "product_id":
            row["product_id"],

        "seller_id":
            row["seller_id"],

        "rating":
            rating,

        "review_title":
            random.choice(
                review_titles[rating]
            ),

        "review_text":
            random.choice(
                review_texts[rating]
            ),

        "review_date":
            review_date.date(),

        "purchase_verified":
            True,

        "helpful_votes":
            helpful_votes,

        "helpfulness_score":
            round(
                min(
                    helpful_votes / 100,
                    1
                ),
                2
            ),

        "sentiment":
            sentiment_map[rating],

        "has_review_images":
            has_review_images,

        "review_source":
            review_source,

        "review_status":
            review_status,

        "seller_response_status":
            seller_response_status,

        "seller_response":
            seller_response

    })


    review_id += 1



# =====================================================
# Create Reviews DataFrame
# =====================================================

reviews_df = pd.DataFrame(reviews)


reviews_df.sort_values(
    by="review_id",
    inplace=True
)


reviews_df.to_csv(
    DATA_DIR / "reviews.csv",
    index=False
)


print("\n" + "=" * 50)
print("✅ Reviews dataset generated successfully!")
print("=" * 50)
print(f"Total Reviews : {len(reviews_df):,}")
print(f"File Saved To : {DATA_DIR / 'reviews.csv'}")
print("=" * 50)