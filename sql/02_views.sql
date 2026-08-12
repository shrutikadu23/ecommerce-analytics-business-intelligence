-- ============================================================
-- E-Commerce Analytics Project
-- Views
-- ============================================================
--
-- Purpose:
-- Contains reusable analytical views used throughout the
-- Sales, Customer, Product, Seller, Inventory, and Returns
-- analysis modules.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================


-- ============================================================
-- View: Sales Summary
-- ============================================================
--
-- Purpose:
-- Provides order-level sales information for reporting and
-- dashboards. Includes all order statuses.
--
-- ============================================================

CREATE OR REPLACE VIEW vw_sales_summary AS

SELECT

    o.order_id,

    o.order_date,

    c.customer_id,

    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    a.city,

    a.state,

    p.payment_method,

    o.order_status,

    o.order_source,

    SUM(oi.quantity) AS total_items,

    SUM(
        (oi.unit_price * oi.quantity)
        - oi.discount_amount
    ) AS total_revenue

FROM orders o

JOIN customers c
ON o.customer_id = c.customer_id

JOIN addresses a
ON o.address_id = a.address_id

JOIN order_items oi
ON o.order_id = oi.order_id

JOIN payments p
ON o.order_id = p.order_id

GROUP BY

    o.order_id,
    o.order_date,
    c.customer_id,
    customer_name,
    a.city,
    a.state,
    p.payment_method,
    o.order_status,
    o.order_source;



-- ============================================================
-- View: Completed Sales
-- ============================================================
--
-- Purpose:
-- Contains only successfully delivered orders.
-- Used by Sales Analysis and Customer Analysis.
--
-- ============================================================

CREATE OR REPLACE VIEW vw_sales_completed AS

SELECT *

FROM vw_sales_summary

WHERE order_status = 'Delivered';