-- ============================================================
-- E-Commerce Analytics Project
-- Product Analysis
-- ============================================================
--
-- Objective:
-- Analyze product performance, sales contribution, pricing,
-- and inventory opportunities using business-focused SQL queries.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Product KPIs
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Active Products
-- ============================================================
--
-- Business Question:
-- How many products are currently active and available for sale?
--
-- Business Value:
-- Measures the size of the active product catalog available
-- to customers. This KPI helps monitor assortment growth
-- and supports inventory planning.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS total_active_products

FROM products

WHERE is_active = TRUE;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the total number of products currently available
for customers to purchase. Monitoring this KPI helps ensure
the product catalog remains healthy and supports assortment
planning.
*/

-- ============================================================
-- Query 02
-- KPI: Products Ever Sold
-- ============================================================
--
-- Business Question:
-- How many unique products have been sold in completed orders?
--
-- Business Value:
-- Measures the number of products that have generated sales.
-- This KPI helps evaluate product adoption and overall catalog
-- utilization.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(DISTINCT product_id) AS products_sold

FROM order_items oi

JOIN orders o
ON oi.order_id = o.order_id

WHERE o.order_status = 'Delivered';

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the number of unique products that have been
purchased in completed orders. Comparing this KPI with
the total active products helps identify products that
have not yet generated sales.
*/

-- ============================================================
-- Query 03
-- KPI: Inactive Products
-- ============================================================
--
-- Business Question:
-- How many products are currently inactive or discontinued?
--
-- Business Value:
-- Measures the number of products that are no longer available
-- for sale. This KPI helps monitor catalog maintenance,
-- product lifecycle management, and inactive inventory.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS inactive_products

FROM products

WHERE is_active = FALSE;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the number of products that are currently
inactive or discontinued. Monitoring this KPI helps
businesses evaluate catalog quality, product lifecycle,
and opportunities for product reactivation or removal.
*/

-- ============================================================
-- Query 04
-- KPI: Average Selling Price
-- ============================================================
--
-- Business Question:
-- What is the average selling price of active products?
--
-- Business Value:
-- Measures the average selling price of products currently
-- available for purchase, helping evaluate pricing strategy
-- and catalog positioning.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(
        AVG(price),
        2
    ) AS average_selling_price

FROM products

WHERE is_active = TRUE;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the average selling price of active products.
Tracking this KPI helps businesses understand pricing
trends and maintain a balanced product portfolio.
*/

-- ============================================================
-- Query 05
-- KPI: Average Product Rating
-- ============================================================
--
-- Business Question:
-- What is the average customer rating of active products?
--
-- Business Value:
-- Measures overall product quality and customer satisfaction
-- across the active product catalog.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(
        AVG(average_rating),
        2
    ) AS average_product_rating

FROM products

WHERE is_active = TRUE;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the average customer rating across all active
products. A higher rating indicates stronger product
quality and customer satisfaction, while a lower rating
may highlight opportunities for product improvement.
*/

-- ============================================================
-- SECTION 2: Product Performance Analysis
-- Queries 6–10
-- ============================================================

-- ============================================================
-- Query 06
-- KPI: Top 10 Products by Revenue
-- ============================================================
--
-- Business Question:
-- Which products have generated the highest revenue?
--
-- Business Value:
-- Identifies the company's best-performing products,
-- helping optimize inventory, marketing, and pricing
-- strategies.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    p.product_id,

    p.product_name,

    p.brand,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(oi.quantity) AS total_quantity_sold,

    ROUND(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        2
    ) AS total_revenue

FROM products p

JOIN order_items oi
ON p.product_id = oi.product_id

JOIN orders o
ON oi.order_id = o.order_id

WHERE o.order_status = 'Delivered'

GROUP BY

    p.product_id,
    p.product_name,
    p.brand

ORDER BY total_revenue DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights the highest revenue-generating products,
helping the business identify star products for
inventory planning, promotions, and pricing decisions.
*/

-- ============================================================
-- Query 07
-- KPI: Top 10 Products by Quantity Sold
-- ============================================================
--
-- Business Question:
-- Which products have sold the highest number of units?
--
-- Business Value:
-- Identifies the most popular products based on sales volume,
-- helping optimize inventory planning, demand forecasting,
-- and promotional strategies.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    p.product_id,

    p.product_name,

    p.brand,

    SUM(oi.quantity) AS total_quantity_sold,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        2
    ) AS total_revenue

FROM products p

JOIN order_items oi
ON p.product_id = oi.product_id

JOIN orders o
ON oi.order_id = o.order_id

WHERE o.order_status = 'Delivered'

GROUP BY

    p.product_id,
    p.product_name,
    p.brand

ORDER BY

    total_quantity_sold DESC,
    total_revenue DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights the products with the highest sales volume.
These products represent strong customer demand and can
guide inventory planning, procurement, and marketing
campaigns.
*/

-- ============================================================
-- Query 08
-- KPI: Top 10 Highest Rated Products
-- ============================================================
--
-- Business Question:
-- Which products have the highest average customer ratings?
--
-- Business Value:
-- Identifies products with the strongest customer satisfaction,
-- helping prioritize premium products for promotions and
-- recommendations.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    product_id,

    product_name,

    brand,

    average_rating,

    total_reviews,

    price

FROM products

WHERE is_active = TRUE

ORDER BY

    average_rating DESC,
    total_reviews DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights products with the highest customer ratings.
Products with consistently high ratings can be promoted
to improve customer trust and increase sales.
*/

-- ============================================================
-- Query 09
-- KPI: Top 10 Most Reviewed Products
-- ============================================================
--
-- Business Question:
-- Which products have received the highest number of customer
-- reviews?
--
-- Business Value:
-- Identifies products with the highest customer engagement,
-- helping businesses understand product popularity and build
-- customer trust through social proof.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    product_id,

    product_name,

    brand,

    total_reviews,

    average_rating,

    price

FROM products

WHERE is_active = TRUE

ORDER BY

    total_reviews DESC,
    average_rating DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights the products with the highest number of customer
reviews. Products receiving many reviews often indicate
strong customer engagement and can increase buyer confidence
through social proof.
*/

-- ============================================================
-- Query 10
-- KPI: Revenue Contribution of Top 10 Products
-- ============================================================
--
-- Business Question:
-- How much revenue do the company's top 10 products
-- contribute, and what is each product's share?
--
-- Business Value:
-- Identifies whether a small number of products generate a
-- significant portion of revenue, helping prioritize inventory,
-- pricing strategies, and promotional efforts.
--
-- SQL Difficulty:
-- Advanced (CTE + Window Functions)
-- ============================================================

WITH product_revenue AS (

    SELECT

        p.product_id,

        p.product_name,

        p.brand,

        ROUND(
            SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
            2
        ) AS total_revenue

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY

        p.product_id,
        p.product_name,
        p.brand

),

top_10 AS (

    SELECT *

    FROM product_revenue

    ORDER BY total_revenue DESC

    LIMIT 10

)

SELECT

    product_id,

    product_name,

    brand,

    total_revenue,

    ROUND(

        total_revenue * 100.0 /

        (
            SELECT
                SUM((oi.quantity * oi.unit_price) - oi.discount_amount)

            FROM order_items oi

            JOIN orders o
                ON oi.order_id = o.order_id

            WHERE o.order_status = 'Delivered'
        ),

        2

    ) AS product_revenue_percentage,

    ROUND(

        SUM(total_revenue) OVER () * 100.0 /

        (
            SELECT
                SUM((oi.quantity * oi.unit_price) - oi.discount_amount)

            FROM order_items oi

            JOIN orders o
                ON oi.order_id = o.order_id

            WHERE o.order_status = 'Delivered'
        ),

        2

    ) AS top_10_revenue_percentage

FROM top_10

ORDER BY total_revenue DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Shows each top product's contribution to total company
revenue while also displaying the combined revenue share
of the top 10 products.

A high combined contribution indicates that a small number
of products generate a significant portion of total revenue,
highlighting their importance for inventory management,
pricing strategies, and promotional campaigns.

The repeated Top 10 Revenue Percentage column provides the
overall contribution of the company's top 10 products
without requiring a separate summary query.
*/

-- ============================================================
-- SECTION 3: Category Performance
-- Queries 11–13
-- ============================================================

-- ============================================================
-- Query 11
-- KPI: Revenue by Category
-- ============================================================
--
-- Business Question:
-- Which product categories generate the highest revenue from
-- completed orders?
--
-- Business Value:
-- Identifies the company's highest-performing product
-- categories based on revenue. This analysis helps optimize
-- product assortment, inventory investment, marketing
-- campaigns, and strategic business planning.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    c.category_id,

    c.category_name,

    COUNT(DISTINCT oi.order_id) AS completed_orders,

    SUM(oi.quantity) AS total_quantity_sold,

    ROUND(

        SUM(
            (oi.quantity * oi.unit_price)
            - oi.discount_amount
        ),

        2

    ) AS total_revenue,

    ROUND(

        AVG(
            (oi.quantity * oi.unit_price)
            - oi.discount_amount
        ),

        2

    ) AS average_revenue_per_order

FROM categories c

JOIN products p
ON c.category_id = p.category_id

JOIN order_items oi
ON p.product_id = oi.product_id

JOIN orders o
ON oi.order_id = o.order_id

WHERE

    o.order_status = 'Delivered'

    AND p.is_active = TRUE

GROUP BY

    c.category_id,
    c.category_name

ORDER BY

    total_revenue DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Ranks product categories based on total revenue generated
from completed orders while also showing completed orders,
units sold, and average revenue per order.

Electronics is the highest revenue-generating category,
indicating strong customer demand and high-value purchases.
Categories with high order volumes but relatively lower
average revenue per order may benefit from pricing
optimization, premium product expansion, or cross-selling
strategies to improve profitability.
*/

-- ============================================================
-- Query 12
-- KPI: Quantity Sold by Category
-- ============================================================
--
-- Business Question:
-- Which product categories have sold the highest number of
-- units through completed orders?
--
-- Business Value:
-- Measures product demand across categories based on units
-- sold rather than revenue. This helps identify high-demand
-- categories for inventory planning, demand forecasting,
-- procurement, and supply chain optimization.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    c.category_id,

    c.category_name,

    SUM(oi.quantity) AS total_quantity_sold,

    COUNT(DISTINCT oi.order_id) AS completed_orders,

    ROUND(

        SUM(
            (oi.quantity * oi.unit_price)
            - oi.discount_amount
        ),

        2

    ) AS total_revenue,

    ROUND(

        AVG(
            (oi.quantity * oi.unit_price)
            - oi.discount_amount
        ),

        2

    ) AS average_revenue_per_order

FROM categories c

JOIN products p
ON c.category_id = p.category_id

JOIN order_items oi
ON p.product_id = oi.product_id

JOIN orders o
ON oi.order_id = o.order_id

WHERE

    o.order_status = 'Delivered'

    AND p.is_active = TRUE

GROUP BY

    c.category_id,
    c.category_name

ORDER BY

    total_quantity_sold DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Ranks product categories by the total number of units sold,
providing insight into customer demand across the product
catalog. Categories with high sales volume require efficient
inventory replenishment and demand forecasting, while
categories with lower sales volumes may benefit from targeted
marketing, pricing adjustments, or assortment optimization.
*/

-- ============================================================
-- Query 13 — Category Revenue Contribution
-- ============================================================
--
-- Business Question:
-- How much does each product category contribute to the
-- company's total revenue?
--
-- Business Value:
-- Identifies the categories that contribute the largest
-- share of overall revenue. This helps management prioritize
-- high-value categories for inventory investment, marketing
-- campaigns, pricing strategies, and future business growth.
--
-- Business Users:
-- Product Manager
-- Category Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    c.category_id,

    c.category_name,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(oi.quantity) AS total_units_sold,

    ROUND(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        2
    ) AS total_revenue,

    ROUND(

        SUM((oi.quantity * oi.unit_price) - oi.discount_amount)
        * 100.0
        /

        SUM(
            SUM((oi.quantity * oi.unit_price) - oi.discount_amount)
        ) OVER (),

        2

    ) AS revenue_percentage

FROM categories c

JOIN products p
    ON c.category_id = p.category_id

JOIN order_items oi
    ON p.product_id = oi.product_id

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Delivered'

GROUP BY

    c.category_id,
    c.category_name

ORDER BY

    total_revenue DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:

Shows each product category's contribution to total company
revenue. Categories with the highest revenue share represent
the company's primary revenue drivers and should be prioritized
for inventory investment, marketing campaigns, pricing
optimization, and long-term growth strategies.

Comparing revenue contribution with units sold helps identify
whether a category succeeds through premium pricing or high
sales volume.
*/

-- ============================================================
-- SECTION 4: Pricing & Profitability Analysis
-- Queries 14–16
-- ============================================================

-- ============================================================
-- Query 14 — Most Expensive Products
-- ============================================================
--
-- Business Question:
-- Which products have the highest selling prices?
--
-- Business Value:
-- Identifies premium-priced products within the catalog,
-- helping evaluate pricing strategy, premium positioning,
-- and opportunities for targeted marketing.
--
-- Business Users:
-- Product Manager
-- Pricing Analyst
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    product_id,

    product_name,

    brand,

    ROUND(price, 2) AS selling_price,

    average_rating,

    total_reviews

FROM products

WHERE is_active = TRUE

ORDER BY

    price DESC,
    average_rating DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Highlights the company's highest-priced products. Comparing
selling prices with customer ratings and review counts helps
evaluate whether premium-priced products are delivering
strong customer value and supporting the company's pricing
strategy.
*/

-- ============================================================
-- Query 15 — Top 10 Products by Profit Margin
-- ============================================================
--
-- Business Question:
-- Which products generate the highest profit margins?
--
-- Business Value:
-- Identifies products with the highest profitability rather
-- than just the highest revenue. This helps optimize pricing,
-- product assortment, and promotional strategies while
-- maximizing overall business profit.
--
-- Business Users:
-- Product Manager
-- Finance Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    product_id,

    product_name,

    brand,

    ROUND(price, 2) AS selling_price,

    ROUND(cost_price, 2) AS cost_price,

    ROUND(price - cost_price, 2) AS profit_per_unit,

    ROUND(
        ((price - cost_price) * 100.0) / price,
        2
    ) AS profit_margin_percentage

FROM products

WHERE is_active = TRUE

ORDER BY

    profit_margin_percentage DESC,
    profit_per_unit DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Ranks products based on profit margin percentage rather
than sales volume. High-margin products generate greater
profit for every unit sold and are ideal candidates for
marketing campaigns, premium positioning, and cross-selling
strategies to improve overall business profitability.
*/

-- ============================================================
-- Query 16 — Most Profitable Categories
-- ============================================================
--
-- Business Question:
-- Which product categories generate the highest estimated
-- gross profit?
--
-- Business Value:
-- Identifies the categories contributing the most profit,
-- helping management prioritize pricing strategies,
-- inventory investment, supplier negotiations, and
-- category expansion decisions.
--
-- Business Users:
-- Product Manager
-- Finance Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    c.category_id,

    c.category_name,

    COUNT(DISTINCT p.product_id) AS total_products,

    SUM(oi.quantity) AS total_units_sold,

    ROUND(

        SUM(
            oi.quantity * (p.price - p.cost_price)
        ),

        2

    ) AS estimated_gross_profit,

    ROUND(

        AVG(
            ((p.price - p.cost_price) * 100.0) / p.price
        ),

        2

    ) AS average_profit_margin

FROM categories c

JOIN products p
    ON c.category_id = p.category_id

JOIN order_items oi
    ON p.product_id = oi.product_id

JOIN orders o
    ON oi.order_id = o.order_id

WHERE

    o.order_status = 'Delivered'

GROUP BY

    c.category_id,
    c.category_name

ORDER BY

    estimated_gross_profit DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Ranks product categories by estimated gross profit rather
than revenue alone. Categories with the highest gross profit
contribute the most to business profitability and should be
prioritized for inventory planning, supplier negotiations,
pricing optimization, and future investment.

Comparing gross profit with revenue helps identify whether
high-revenue categories are also the most profitable.
*/