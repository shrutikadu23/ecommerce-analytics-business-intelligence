import pandas as pd
import random
from pathlib import Path


# =====================================================
# Configuration
# =====================================================

random.seed(42)

DATA_DIR = Path(__file__).resolve().parent.parent / "datasets"


RETURN_PROBABILITY = 0.08
RETURN_WINDOW_DAYS = 30

MIN_REVERSE_SHIPPING_COST = 30
MAX_REVERSE_SHIPPING_COST = 180


# =====================================================
# Load Datasets
# =====================================================

order_items = pd.read_csv(
    DATA_DIR / "order_items.csv"
)

orders = pd.read_csv(
    DATA_DIR / "orders.csv"
)

products = pd.read_csv(
    DATA_DIR / "products.csv"
)

shipments = pd.read_csv(
    DATA_DIR / "shipments.csv"
)


# =====================================================
# Create Order Item ID
# =====================================================

order_items.insert(
    0,
    "order_item_id",
    range(
        1,
        len(order_items) + 1
    )
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
# Delivered Shipments Only
# =====================================================

delivered_shipments = shipments[
    shipments["delivery_status"] == "Delivered"
]


# =====================================================
# Merge Orders + Delivery
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
# Merge Order Items
# =====================================================

return_base = order_items.merge(
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
# Merge Products
# =====================================================

return_base = return_base.merge(
    products[
        [
            "product_id",
            "seller_id",
            "category_id"
        ]
    ],
    on="product_id",
    how="inner"
)


print(
    f"Eligible Delivered Items: {len(return_base):,}"
)


# =====================================================
# Return Reason Logic
# =====================================================

def get_return_reason(category_id):

    electronics = [
        "Damaged Product",
        "Missing Parts",
        "Quality Issue",
        "Product Not As Expected"
    ]


    fashion = [
        "Size/Fit Issue",
        "Changed Mind",
        "Wrong Product",
        "Product Not As Expected"
    ]


    general = [
        "Wrong Product",
        "Damaged Product",
        "Quality Issue",
        "Changed Mind",
        "Late Delivery",
        "Product Not As Expected"
    ]


    if category_id in [1, 2]:

        return random.choice(
            electronics
        )


    elif category_id in [3, 4]:

        return random.choice(
            fashion
        )


    return random.choice(
        general
    )


# =====================================================
# Master Values
# =====================================================

return_types = [
    "Refund",
    "Replacement",
    "Exchange"
]

return_type_weights = [
    60,
    30,
    10
]


return_channels = [
    "Mobile App",
    "Website",
    "Customer Support"
]

return_channel_weights = [
    50,
    40,
    10
]


return_statuses = [
    "Requested",
    "Approved",
    "Pickup Scheduled",
    "Picked Up",
    "Completed",
    "Rejected"
]

return_status_weights = [
    10,
    20,
    15,
    15,
    35,
    5
]


refund_statuses = [
    "Pending",
    "Processing",
    "Completed"
]


pickup_statuses = [
    "Pending",
    "Scheduled",
    "Completed",
    "Failed"
]


quality_statuses = [
    "Pending",
    "Passed",
    "Failed"
]


return_conditions = [
    "Unused",
    "Opened",
    "Used",
    "Damaged"
]


replacement_statuses = [
    "Requested",
    "Processing",
    "Completed",
    "Cancelled"
]


# =====================================================
# Helper Function
# =====================================================

def generate_reverse_shipping_cost():

    return round(
        random.uniform(
            MIN_REVERSE_SHIPPING_COST,
            MAX_REVERSE_SHIPPING_COST
        ),
        2
    )

# =====================================================
# Generate Returns
# =====================================================

returns = []

return_id = 1


for _, row in return_base.iterrows():

    # Return probability check

    if random.random() > RETURN_PROBABILITY:
        continue


    delivery_date = row["actual_delivery_date"]


    days_after_delivery = random.randint(
        1,
        RETURN_WINDOW_DAYS
    )


    return_date = (
        delivery_date
        +
        pd.Timedelta(
            days=days_after_delivery
        )
    )


    # Return Type

    return_type = random.choices(
        return_types,
        weights=return_type_weights,
        k=1
    )[0]


    # Return Status

    return_status = random.choices(
        return_statuses,
        weights=return_status_weights,
        k=1
    )[0]


    # Reason

    return_reason = get_return_reason(
        row["category_id"]
    )


    # Channel

    return_channel = random.choices(
        return_channels,
        weights=return_channel_weights,
        k=1
    )[0]



    # =================================================
    # Refund Logic
    # =================================================

    if return_type == "Refund":

        refund_amount = round(
           (row["quantity"] * row["unit_price"]) - row["discount_amount"],
            2
        )


        if return_status == "Rejected":

            refund_status = "Not Applicable"
            refund_amount = 0


        elif return_status == "Completed":

            refund_status = random.choices(
                [
                    "Pending",
                    "Processing",
                    "Completed"
                ],
                weights=[
                    10,
                    20,
                    70
                ],
                k=1
            )[0]


        else:

            refund_status = random.choice(
                [
                    "Pending",
                    "Processing"
                ]
            )


    else:

        refund_amount = 0
        refund_status = "Not Applicable"



    # =================================================
    # Pickup Logic
    # =================================================

    if return_status in [
        "Requested",
        "Approved"
    ]:

        pickup_status = random.choice(
            [
                "Pending",
                "Scheduled"
            ]
        )


    elif return_status in [
        "Pickup Scheduled",
        "Picked Up"
    ]:

        pickup_status = random.choice(
            [
                "Scheduled",
                "Completed"
            ]
        )


    elif return_status == "Completed":

        pickup_status = "Completed"


    else:

        pickup_status = "Failed"



    if pickup_status in [
        "Scheduled",
        "Completed"
    ]:

        pickup_date = (
            return_date
            +
            pd.Timedelta(
                days=random.randint(1,3)
            )
        )

    else:

        pickup_date = None



    # =================================================
    # Quality Check Logic
    # =================================================

    if pickup_status == "Completed":

        quality_check_status = random.choices(
            quality_statuses,
            weights=[
                15,
                75,
                10
            ],
            k=1
        )[0]

    else:

        quality_check_status = "Pending"



    # =================================================
    # Return Condition
    # =================================================

    if quality_check_status == "Failed":

        return_condition = "Damaged"

    else:

        return_condition = random.choice(
            return_conditions
        )



    # =================================================
    # Replacement Logic
    # =================================================

    replacement_requested = (

        True
        if return_type in [
            "Replacement",
            "Exchange"
        ]

        else False
    )


    if replacement_requested:

        replacement_status = random.choice(
            [
                "Requested",
                "Processing",
                "Completed",
                "Cancelled"
            ]
        )

    else:

        replacement_status = "Not Applicable"



    # =================================================
    # Store Record
    # =================================================

    returns.append({

        "return_id":
            return_id,

        "order_id":
            row["order_id"],

        "order_item_id":
            row["order_item_id"],

        "customer_id":
            row["customer_id"],

        "product_id":
            row["product_id"],

        "seller_id":
            row["seller_id"],


        "return_date":
            return_date.date(),


        "days_after_delivery":
            days_after_delivery,


        "return_type":
            return_type,


        "return_reason":
            return_reason,


        "return_channel":
            return_channel,


        "return_status":
            return_status,


        "refund_status":
            refund_status,


        "refund_amount":
            refund_amount,


        "reverse_shipping_cost":
            generate_reverse_shipping_cost(),


        "pickup_status":
            pickup_status,


        "pickup_date":
            pickup_date.date()
            if pickup_date
            else None,


        "quality_check_status":
            quality_check_status,


        "return_condition":
            return_condition,


        "replacement_requested":
            replacement_requested,


        "replacement_status":
            replacement_status

    })


    return_id += 1



# =====================================================
# Save Dataset
# =====================================================

returns_df = pd.DataFrame(
    returns
)


returns_df.to_csv(
    DATA_DIR / "returns.csv",
    index=False
)


print("\n" + "="*50)
print("✅ Returns dataset generated successfully!")
print("="*50)

print(
    f"Total Returns : {len(returns_df):,}"
)

print(
    f"File Saved To : {DATA_DIR / 'returns.csv'}"
)

print("="*50)