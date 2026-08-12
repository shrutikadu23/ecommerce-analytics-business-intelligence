import random
import string
from pathlib import Path
from datetime import datetime, timedelta

import pandas as pd

# ======================================================
# Configuration
# ======================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_FOLDER = BASE_DIR / "datasets"

ORDERS_FILE = DATA_FOLDER / "orders.csv"
OUTPUT_FILE = DATA_FOLDER / "payments.csv"

random.seed(42)

CURRENCY = "INR"

PAYMENT_METHODS = [
    "UPI",
    "Credit Card",
    "Debit Card",
    "Net Banking",
    "Wallet",
    "Cash on Delivery"
]

PAYMENT_METHOD_WEIGHTS = [
    35,
    25,
    15,
    10,
    10,
    5
]

GATEWAY_MAPPING = {
    "UPI": (
        ["PhonePe", "Paytm", "Razorpay"],
        [50, 30, 20]
    ),

    "Credit Card": (
        ["Razorpay", "Stripe"],
        [70, 30]
    ),

    "Debit Card": (
        ["Razorpay", "Stripe"],
        [65, 35]
    ),

    "Net Banking": (
        ["Razorpay"],
        [100]
    ),

    "Wallet": (
        ["Paytm"],
        [100]
    ),

    "Cash on Delivery": (
        ["Cash on Delivery"],
        [100]
    )
}

PROCESSING_FEES = {
    "UPI": 0.0100,
    "Credit Card": 0.0250,
    "Debit Card": 0.0200,
    "Net Banking": 0.0175,
    "Wallet": 0.0150,
    "Cash on Delivery": 0.0000
}

used_transaction_ids = set()

# ======================================================
# Helper Functions
# ======================================================

def generate_transaction_id():

    while True:

        txn = "TXN" + "".join(
            random.choices(
                string.ascii_uppercase + string.digits,
                k=12
            )
        )

        if txn not in used_transaction_ids:
            used_transaction_ids.add(txn)
            return txn


def get_gateway(payment_method):

    gateways, weights = GATEWAY_MAPPING[payment_method]

    return random.choices(
        gateways,
        weights=weights,
        k=1
    )[0]


# ======================================================
# Load Orders
# ======================================================

orders_df = pd.read_csv(
    ORDERS_FILE,
    dayfirst=True
)

print(f"Orders Loaded : {len(orders_df)}")

# ======================================================
# Generate Payments
# ======================================================

payments = []

payment_id = 1

for _, order in orders_df.iterrows():

    order_date = datetime.strptime(
        str(order["order_date"]),
        "%d-%m-%Y"
    )

    delivery_date = datetime.strptime(
        str(order["expected_delivery_date"]),
        "%d-%m-%Y"
    )

    order_status = str(order["order_status"]).strip()

    total_amount = round(
        float(order["total_amount"]),
        2
    )

    payment_method = random.choices(
        PAYMENT_METHODS,
        weights=PAYMENT_METHOD_WEIGHTS,
        k=1
    )[0]

    gateway = get_gateway(
        payment_method
    )

    fee_rate = PROCESSING_FEES[
        payment_method
    ]

        # ======================================================
    # Payment Status
    # ======================================================

    if order_status == "Delivered":
        payment_status = "Completed"

    elif order_status == "Returned":
        payment_status = "Refunded"

    elif order_status == "Shipped":
        payment_status = random.choices(
            ["Completed", "Failed"],
            weights=[95, 5],
            k=1
        )[0]

    elif order_status == "Confirmed":
        payment_status = random.choices(
            ["Completed", "Pending"],
            weights=[90, 10],
            k=1
        )[0]

    elif order_status == "Pending":
        payment_status = random.choices(
            ["Pending", "Failed"],
            weights=[90, 10],
            k=1
        )[0]

    else:
        payment_status = "Completed"

    # ======================================================
    # Payment Timestamp
    # ======================================================

    if payment_method == "Cash on Delivery":

        payment_datetime = delivery_date + timedelta(
            hours=random.randint(9, 20),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )

    elif payment_method in ["UPI", "Wallet"]:

        payment_datetime = order_date + timedelta(
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )

    elif payment_method in ["Credit Card", "Debit Card"]:

        payment_datetime = order_date + timedelta(
            days=random.randint(0, 1),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )

    else:  # Net Banking

        payment_datetime = order_date + timedelta(
            days=random.randint(0, 2),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )

    # ======================================================
    # Amount & Refund
    # ======================================================

    if payment_status == "Completed":

        amount_paid = total_amount
        refund_amount = 0.00

    elif payment_status == "Refunded":

        amount_paid = total_amount
        refund_amount = total_amount

    elif payment_status == "Pending":

        amount_paid = 0.00
        refund_amount = 0.00

    else:  # Failed

        amount_paid = 0.00
        refund_amount = 0.00

    # ======================================================
    # COD Validation
    # ======================================================

    if (
        payment_method == "Cash on Delivery"
        and payment_status == "Pending"
    ):

        payment_status = "Completed"
        amount_paid = total_amount
        refund_amount = 0.00

    # ======================================================
    # Processing Fee
    # ======================================================

    payment_processing_fee = round(
        amount_paid * fee_rate,
        2
    )

    # ======================================================
    # Save Record
    # ======================================================

    payments.append({

        "payment_id": payment_id,
        "order_id": int(order["order_id"]),

        "payment_timestamp":
            payment_datetime.strftime("%d-%m-%Y %H:%M:%S"),

        "payment_method": payment_method,

        "gateway_name": gateway,

        "payment_status": payment_status,

        "amount_paid": round(
            amount_paid,
            2
        ),

        "payment_processing_fee":
            payment_processing_fee,

        "refund_amount": round(
            refund_amount,
            2
        ),

        "currency": CURRENCY,

        "transaction_id":
            generate_transaction_id()

    })

    payment_id += 1


# ======================================================
# Create DataFrame
# ======================================================

payments_df = pd.DataFrame(payments)

payments_df.sort_values(
    by="payment_id",
    inplace=True
)

payments_df.reset_index(
    drop=True,
    inplace=True
)

# ======================================================
# Save CSV
# ======================================================

payments_df.to_csv(
    OUTPUT_FILE,
    index=False
)

# ======================================================
# Summary
# ======================================================

print("-" * 45)
print(f"Generated Payments : {len(payments_df)}")
print(f"Completed Payments : {(payments_df['payment_status'] == 'Completed').sum()}")
print(f"Pending Payments   : {(payments_df['payment_status'] == 'Pending').sum()}")
print(f"Failed Payments    : {(payments_df['payment_status'] == 'Failed').sum()}")
print(f"Refunded Payments  : {(payments_df['payment_status'] == 'Refunded').sum()}")
print("-" * 45)
print(f"Saved to {OUTPUT_FILE}")