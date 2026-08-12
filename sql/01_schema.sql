-- ============================================
-- Amazon E-Commerce Database Schema
-- PostgreSQL 18
-- ============================================

-- ============================================
-- Table: Customers
-- ============================================

CREATE TABLE customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    join_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ============================================
-- Table: Addresses
-- ============================================

CREATE TABLE addresses (
    address_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    country VARCHAR(100) NOT NULL,
    address_type VARCHAR(20) NOT NULL,

    CONSTRAINT fk_addresses_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

-- ============================================
-- Table: Categories
-- ============================================

CREATE TABLE categories (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    category_name VARCHAR(100) NOT NULL UNIQUE,

    description TEXT
);

-- ============================================
-- Table: Sellers
-- ============================================

CREATE TABLE sellers (
    seller_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    seller_name VARCHAR(100) NOT NULL,

    seller_email VARCHAR(100) NOT NULL UNIQUE,

    seller_phone VARCHAR(15) NOT NULL UNIQUE,

    city VARCHAR(100) NOT NULL,

    state VARCHAR(100) NOT NULL,

    specialization_category_id INT NOT NULL,

    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,

    seller_rating DECIMAL(2,1)
        CHECK (seller_rating BETWEEN 0 AND 5),

        seller_status VARCHAR(20)
    NOT NULL DEFAULT 'Active'
    CHECK (seller_status IN ('Active', 'Inactive', 'Suspended')),

is_verified BOOLEAN NOT NULL DEFAULT TRUE,

CONSTRAINT fk_sellers_category
FOREIGN KEY (specialization_category_id)
REFERENCES categories(category_id)
ON DELETE RESTRICT

);

-- ============================================
-- Table: Products
-- ============================================

CREATE TABLE products (
    product_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    product_name VARCHAR(255) NOT NULL,

    category_id INT NOT NULL,

    seller_id INT NOT NULL,

    brand VARCHAR(50) NOT NULL,

    stock_keeping_unit VARCHAR(30) UNIQUE NOT NULL,

    price DECIMAL(10,2) NOT NULL
        CHECK (price > 0),

    cost_price DECIMAL(10,2) NOT NULL
        CHECK (cost_price > 0 AND cost_price <= price),

    discount_percentage DECIMAL(5,2) NOT NULL DEFAULT 0
        CHECK (discount_percentage BETWEEN 0 AND 100),

    description TEXT,

    average_rating DECIMAL(2,1)DEFAULT 0
        CHECK (average_rating BETWEEN 0 AND 5),

    total_reviews INT NOT NULL DEFAULT 0
        CHECK (total_reviews >= 0),

    launch_date DATE NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_products_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
        ON DELETE RESTRICT
);

-- ============================================
-- Table: Inventory
-- ============================================

CREATE TABLE inventory (
    inventory_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    product_id INT NOT NULL UNIQUE,

    stock_quantity INT NOT NULL
        CHECK (stock_quantity >= 0),

    reorder_level INT NOT NULL DEFAULT 10
        CHECK (reorder_level >= 0),

    last_restock_date DATE NOT NULL,

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);

-- ============================================
-- Table: Orders
-- ============================================

CREATE TABLE orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id INT NOT NULL,

    address_id INT NOT NULL,

    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    order_status VARCHAR(30) NOT NULL
        CHECK (order_status IN ('Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled', 'Returned')),

    total_amount DECIMAL(10,2) NOT NULL
        CHECK (total_amount >= 0),

    order_source VARCHAR(20) NOT NULL
        CHECK (order_source IN ('Website', 'Mobile App')),

        expected_delivery_date DATE NOT NULL,

CHECK (expected_delivery_date >= order_date::DATE),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_address
        FOREIGN KEY (address_id)
        REFERENCES addresses(address_id)
        ON DELETE RESTRICT
);

-- ============================================
-- Table: Order_Items
-- ============================================

CREATE TABLE order_items (
    order_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_id INT NOT NULL,

    product_id INT NOT NULL,

    quantity INT NOT NULL
        CHECK (quantity > 0),

    unit_price DECIMAL(10,2) NOT NULL
        CHECK (unit_price >= 0),

    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0
        CHECK (discount_amount >= 0),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT
);

-- ============================================
-- Table: Payments
-- ============================================

CREATE TABLE payments (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_id INT NOT NULL UNIQUE,

    payment_timestamp TIMESTAMP NOT NULL,

    payment_method VARCHAR(30) NOT NULL
        CHECK (payment_method IN ('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash on Delivery', 'Wallet')),

    gateway_name VARCHAR(50) NOT NULL,

    payment_status VARCHAR(20) NOT NULL
        CHECK (payment_status IN ('Pending', 'Completed', 'Failed', 'Refunded')),

    amount_paid DECIMAL(10,2) NOT NULL
        CHECK (amount_paid >= 0),

    payment_processing_fee DECIMAL(10,2) NOT NULL
        CHECK (payment_processing_fee >= 0),

    refund_amount DECIMAL(10,2) NOT NULL DEFAULT 0
        CHECK (refund_amount >= 0),

    currency VARCHAR(10) NOT NULL DEFAULT 'INR',

    transaction_id VARCHAR(100) NOT NULL UNIQUE,

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT
);

-- ============================================
-- Table: Shipments
-- ============================================

CREATE TABLE shipments (
    shipment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_id INT NOT NULL UNIQUE,

    courier_partner VARCHAR(100) NOT NULL,

    delivery_mode VARCHAR(30) NOT NULL
        CHECK (delivery_mode IN ('Standard', 'Express', 'Next Day', 'Same Day')),

    shipment_date TIMESTAMP NOT NULL,

    estimated_delivery_date DATE NOT NULL,

    actual_delivery_date DATE,

    delivery_status VARCHAR(20) NOT NULL
        CHECK (delivery_status IN ('Delivered', 'In Transit', 'Delayed', 'Returned')),

    tracking_number VARCHAR(100) NOT NULL UNIQUE,

    shipping_cost DECIMAL(10,2) NOT NULL
        CHECK (shipping_cost >= 0),

    shipping_distance_km INT NOT NULL
        CHECK (shipping_distance_km > 0),

    warehouse_location VARCHAR(100) NOT NULL,

    delivery_city VARCHAR(100) NOT NULL,

    delivery_attempts INT NOT NULL
        CHECK (delivery_attempts >= 0),

    delivery_rating INT
        CHECK (delivery_rating BETWEEN 1 AND 5),

    on_time_delivery BOOLEAN,

    delay_reason VARCHAR(100),

    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT
);

-- ============================================
-- Table: Reviews
-- ============================================

CREATE TABLE reviews (

    review_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_item_id INT NOT NULL,

    customer_id INT NOT NULL,

    product_id INT NOT NULL,

    seller_id INT NOT NULL,

    rating INT NOT NULL
        CHECK (rating BETWEEN 1 AND 5),

    review_title VARCHAR(255),

    review_text TEXT,

    review_date DATE NOT NULL,

    purchase_verified BOOLEAN NOT NULL DEFAULT TRUE,

    helpful_votes INT NOT NULL DEFAULT 0
        CHECK (helpful_votes >= 0),

    helpfulness_score DECIMAL(3,2)
        CHECK (helpfulness_score BETWEEN 0 AND 1),

    sentiment VARCHAR(20)
        CHECK (sentiment IN ('Positive','Neutral','Negative')),

    has_review_images BOOLEAN DEFAULT FALSE,

    review_source VARCHAR(30)
        CHECK (review_source IN ('Website','Mobile App','Email Campaign')),

    review_status VARCHAR(20)
        CHECK (review_status IN ('Approved','Pending','Rejected')),

    seller_response_status VARCHAR(20)
        CHECK (seller_response_status IN ('Responded','Pending')),

    seller_response TEXT,


    CONSTRAINT fk_reviews_order_item
        FOREIGN KEY(order_item_id)
        REFERENCES order_items(order_item_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reviews_customer
        FOREIGN KEY(customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reviews_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reviews_seller
        FOREIGN KEY(seller_id)
        REFERENCES sellers(seller_id)
        ON DELETE RESTRICT
);

-- ============================================
-- Table: Returns
-- ============================================

CREATE TABLE returns (

    return_id INT PRIMARY KEY,

    order_id INT NOT NULL,

    order_item_id INT NOT NULL,

    customer_id INT NOT NULL,

    product_id INT NOT NULL,

    seller_id INT NOT NULL,

    return_date DATE NOT NULL,

    days_after_delivery INT NOT NULL,

    return_type VARCHAR(20) NOT NULL,

    return_reason VARCHAR(255) NOT NULL,

    return_channel VARCHAR(50) NOT NULL,

    return_status VARCHAR(30) NOT NULL,

    refund_status VARCHAR(30) NOT NULL,

    refund_amount DECIMAL(10,2)
        CHECK (refund_amount >= 0),

    reverse_shipping_cost DECIMAL(10,2)
        CHECK (reverse_shipping_cost >= 0),

    pickup_status VARCHAR(30),

    pickup_date DATE,

    quality_check_status VARCHAR(30),

    return_condition VARCHAR(30),

    replacement_requested BOOLEAN,

    replacement_status VARCHAR(30)
);
-- ============================================
-- Table: Wishlist
-- ============================================

CREATE TABLE wishlist (
    wishlist_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id INT NOT NULL,

    product_id INT NOT NULL,

    added_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    moved_to_cart BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT uq_wishlist_customer_product
        UNIQUE (customer_id, product_id),

    CONSTRAINT fk_wishlist_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wishlist_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);