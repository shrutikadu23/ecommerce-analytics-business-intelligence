# E-Commerce Analytics Database Design

## Project Overview

This project aims to design and build a realistic Amazon-like e-commerce database using PostgreSQL. The database will support business analysis through SQL queries and Power BI dashboards.

---

## Tables

1. Customers
2. Addresses
3. Sellers
4. Categories
5. Products
6. Inventory
7. Orders
8. Order_Items
9. Payments
10. Shipments
11. Reviews
12. Returns

---

# Table 1: Customers

## Purpose

Stores information about every customer who creates an Amazon account.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| customer_id | SERIAL | Unique customer ID |
| first_name | VARCHAR(50) | Customer's first name |
| last_name | VARCHAR(50) | Customer's last name |
| email | VARCHAR(100) | Customer unique email address |
| phone | VARCHAR(15) | Customer's contact number |
| join_date | DATE | Date customer joined Amazon |
|is_active  |(BOOLEAN)| Indicates whether the account is active|
## Primary Key

customer_id

---

# Table 2: Addresses

## Purpose

Stores customer addresses. A customer can have multiple addresses.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| address_id | SERIAL | Unique address ID |
| customer_id | INT | References the customer |
| address_line | VARCHAR(255) | House number, street, area |
| city | VARCHAR(100) | City |
| state | VARCHAR(100) | State |
| pincode | VARCHAR(10) | Postal code |
| country | VARCHAR(100) | Country |
| address_type | VARCHAR(20) | Home, Office, or Other |

## Primary Key

address_id

## Foreign Key

customer_id → Customers(customer_id)

---

# Table 3: Categories

## Purpose

Stores different product categories to organize products.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| category_id | SERIAL | Unique category ID |
| category_name | VARCHAR(100) | Name of the category |
| description | TEXT | Description of the category |

## Primary Key

category_id

---

# Table 4: Sellers

## Purpose

Stores information about sellers who list products on Amazon.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| seller_id | SERIAL | Unique seller ID |
| seller_name | VARCHAR(100) | Seller or company name |
| seller_email | VARCHAR(100) | Seller email |
| seller_phone | VARCHAR(15) | Seller contact number |
| city | VARCHAR(100) | Seller's city |
| state | VARCHAR(100) | Seller's state |
| registration_date | DATE | Date the seller joined Amazon |
| seller_rating | DECIMAL(2,1) | Average seller rating |

## Primary Key

seller_id

---

# Table 5: Products

## Purpose

Stores information about every product available on Amazon.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| product_id | SERIAL | Unique product ID |
| product_name | VARCHAR(255) | Name of the product |
| category_id | INT | Category the product belongs to |
| seller_id | INT | Seller offering the product |
| brand | VARCHAR(100) | Product brand |
| price | DECIMAL(10,2) | Selling price |
| description | TEXT | Product description |
| cost_price | DECIMAL(10,2) | Cost price of the product |
| discount_percentage | DECIMAL(5,2) | Discount percentage |
| average_rating | DECIMAL(2,1) | Average customer rating |
| total_reviews | INT | Total number of customer reviews |
| launch_date | DATE | Product launch date |
| is_active | BOOLEAN | Indicates whether the product is available for sale |
## Primary Key

product_id

## Foreign Keys

category_id → Categories(category_id)

seller_id → Sellers(seller_id)

---

# Table 6: Inventory

## Purpose

Stores stock information for each product.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| inventory_id | SERIAL | Unique inventory record ID |
| product_id | INT | Product in inventory |
| stock_quantity | INT | Number of units available |
| warehouse_location | VARCHAR(100) | Warehouse where the product is stored |
| last_updated | TIMESTAMP | Last inventory update |
| reorder_level | INT | Minimum stock level before restocking |

## Primary Key

inventory_id

## Foreign Key

product_id → Products(product_id)

---

# Table 7: Orders

## Purpose

Stores information about every order placed by customers.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| order_id | SERIAL | Unique order ID |
| customer_id | INT | Customer who placed the order |
| address_id | INT | Delivery address |
| order_date | TIMESTAMP | Date and time the order was placed |
| order_status | VARCHAR(30) | Current status of the order |
| total_amount | DECIMAL(10,2) | Total amount of the order |
| order_source | VARCHAR(20) | Mobile App or Website |
| expected_delivery_date | DATE | Expected delivery date |

## Primary Key

order_id

## Foreign Keys

customer_id → Customers(customer_id)

address_id → Addresses(address_id)

---

# Table 8: Order_Items

## Purpose

Stores the products included in each order.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| order_item_id | SERIAL | Unique order item ID |
| order_id | INT | Order to which the product belongs |
| product_id | INT | Product ordered |
| quantity | INT | Number of units ordered |
| unit_price | DECIMAL(10,2) | Price of one unit at the time of purchase |
| discount_amount | DECIMAL(10,2) | Discount applied to this item |
## Primary Key

order_item_id

## Foreign Keys

order_id → Orders(order_id)

product_id → Products(product_id)

---

# Table 9: Payments

## Purpose

Stores payment details for each order.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| payment_id | SERIAL | Unique payment ID |
| order_id | INT | Order associated with the payment |
| payment_method | VARCHAR(30) | UPI, Credit Card, Debit Card, COD, etc. |
| payment_status | VARCHAR(30) | Success, Pending, Failed, Refunded |
| payment_date | TIMESTAMP | Date and time of payment |
| amount | DECIMAL(10,2) | Amount paid |
| transaction_id | VARCHAR(100) | Payment transaction reference |

## Primary Key

payment_id

## Foreign Key

order_id → Orders(order_id)

---

# Table 10: Shipments

## Purpose

Stores shipping and delivery information for each order.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| shipment_id | SERIAL | Unique shipment ID |
| order_id | INT | Order being shipped |
| courier_name | VARCHAR(100) | Delivery partner |
| tracking_number | VARCHAR(100) | Shipment tracking number |
| shipped_date | TIMESTAMP | Date the order was shipped |
| delivered_date | TIMESTAMP | Date the order was delivered |
| delivery_status | VARCHAR(30) | Shipped, In Transit, Delivered, Cancelled |
| shipping_cost | DECIMAL(10,2) | Shipping cost |

## Primary Key

shipment_id

## Foreign Key

order_id → Orders(order_id)

---

# Table 11: Reviews

## Purpose

Stores customer reviews and ratings for purchased products.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| review_id | SERIAL | Unique review ID |
| product_id | INT | Product being reviewed |
| customer_id | INT | Customer who wrote the review |
| rating | INT | Rating given (1–5) |
| review_text | TEXT | Customer review |
| review_date | TIMESTAMP | Date the review was submitted |

## Primary Key

review_id

## Foreign Keys

product_id → Products(product_id)

customer_id → Customers(customer_id)

---

# Table 12: Returns

## Purpose

Stores information about products returned by customers.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| return_id | SERIAL | Unique return ID |
| order_item_id | INT | Order item being returned |
| return_date | TIMESTAMP | Date the return was requested |
| return_reason | VARCHAR(255) | Reason for the return |
| refund_amount | DECIMAL(10,2) | Amount refunded |
| return_status | VARCHAR(30) | Requested, Approved, Rejected, Refunded |
| refund_status | VARCHAR(30) | Refund processing status |

## Primary Key

return_id

## Foreign Key

order_item_id → Order_Items(order_item_id)

## Purpose

Stores products saved by customers for future purchase.

## Columns

| Column | Data Type | Description |
|---------|-----------|-------------|
| wishlist_id | SERIAL | Unique wishlist ID |
| customer_id | INT | Customer who saved the product |
| product_id | INT | Saved product |
| added_date | TIMESTAMP | Date product was added to the wishlist |
| moved_to_cart | BOOLEAN | Indicates whether the wishlist item was moved to the shopping cart |

## Primary Key

wishlist_id

## Foreign Keys

customer_id → Customers(customer_id)

product_id → Products(product_id)
