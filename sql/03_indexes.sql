-- ============================================================
-- E-Commerce Analytics Database
-- Performance Indexes
-- PostgreSQL 18
-- ============================================================

-- =========================
-- ADDRESSES
-- =========================
CREATE INDEX idx_addresses_customer
ON addresses(customer_id);

-- =========================
-- PRODUCTS
-- =========================
CREATE INDEX idx_products_category
ON products(category_id);

CREATE INDEX idx_products_seller
ON products(seller_id);

CREATE INDEX idx_products_brand
ON products(brand);

-- =========================
-- ORDERS
-- =========================
CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_orders_order_date
ON orders(order_date);

CREATE INDEX idx_orders_status
ON orders(order_status);

CREATE INDEX idx_orders_source
ON orders(order_source);

-- =========================
-- ORDER ITEMS
-- =========================
CREATE INDEX idx_order_items_order
ON order_items(order_id);

CREATE INDEX idx_order_items_product
ON order_items(product_id);

-- =========================
-- PAYMENTS
-- =========================
CREATE INDEX idx_payments_method
ON payments(payment_method);

CREATE INDEX idx_payments_status
ON payments(payment_status);

-- =========================
-- SHIPMENTS
-- =========================
CREATE INDEX idx_shipments_status
ON shipments(delivery_status);

CREATE INDEX idx_shipments_courier
ON shipments(courier_partner);

CREATE INDEX idx_shipments_city
ON shipments(delivery_city);

-- =========================
-- REVIEWS
-- =========================
CREATE INDEX idx_reviews_product
ON reviews(product_id);

CREATE INDEX idx_reviews_seller
ON reviews(seller_id);

CREATE INDEX idx_reviews_customer
ON reviews(customer_id);

CREATE INDEX idx_reviews_sentiment
ON reviews(sentiment);

-- =========================
-- RETURNS
-- =========================
CREATE INDEX idx_returns_product
ON returns(product_id);

CREATE INDEX idx_returns_seller
ON returns(seller_id);

CREATE INDEX idx_returns_status
ON returns(return_status);

CREATE INDEX idx_returns_reason
ON returns(return_reason);

-- =========================
-- WISHLIST
-- =========================
CREATE INDEX idx_wishlist_customer
ON wishlist(customer_id);

CREATE INDEX idx_wishlist_product
ON wishlist(product_id);