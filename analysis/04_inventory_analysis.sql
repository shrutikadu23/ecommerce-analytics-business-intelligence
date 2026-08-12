-- ============================================================
-- E-Commerce Analytics Project
-- Inventory Analysis
-- ============================================================
--
-- Objective:
-- Analyze inventory availability, stock levels, and inventory
-- value using business-focused SQL queries.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Inventory KPIs
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Products in Inventory
-- ============================================================
--
-- Business Question:
-- How many products are currently tracked in inventory?
--
-- Business Value:
-- Measures the number of products currently managed within
-- the inventory system. This KPI helps monitor inventory
-- coverage and product availability.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS total_products_in_inventory

FROM inventory;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the total number of products currently tracked
in inventory. Comparing this value with the total active
products helps identify products that may not yet have
inventory records.
*/

-- ============================================================
-- Query 02
-- KPI: Total Stock Available
-- ============================================================
--
-- Business Question:
-- How many units are currently available across all products?
--
-- Business Value:
-- Measures the total inventory available for sale across the
-- entire product catalog. This KPI helps monitor inventory
-- capacity and supports replenishment planning.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    SUM(stock_quantity) AS total_stock_available

FROM inventory;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the total number of product units currently
available in inventory. Monitoring this KPI helps ensure
sufficient stock levels to meet customer demand while
supporting inventory planning and warehouse management.
*/

-- ============================================================
-- Query 03
-- KPI: Products Below Reorder Level
-- ============================================================
--
-- Business Question:
-- How many products have stock levels below their reorder level?
--
-- Business Value:
-- Identifies products that require immediate replenishment,
-- helping prevent stockouts and ensuring product availability.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS products_below_reorder_level

FROM inventory

WHERE stock_quantity < reorder_level;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the number of products that have fallen below
their predefined reorder level. Monitoring this KPI helps
inventory managers replenish stock before products become
out of stock, reducing lost sales and improving customer
satisfaction.
*/

-- ============================================================
-- Query 04
-- KPI: Out of Stock Products
-- ============================================================
--
-- Business Question:
-- How many products are currently out of stock?
--
-- Business Value:
-- Measures inventory availability by identifying products
-- that cannot currently be sold. This KPI helps reduce lost
-- sales and improve replenishment planning.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS out_of_stock_products

FROM inventory

WHERE stock_quantity = 0;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the number of products that are currently
out of stock. A high value may indicate supply chain
issues or inaccurate inventory planning, potentially
leading to lost sales and reduced customer satisfaction.
*/

-- ============================================================
-- Query 05
-- KPI: Average Inventory per Product
-- ============================================================
--
-- Business Question:
-- What is the average stock quantity available per product?
--
-- Business Value:
-- Measures the average inventory available for each product,
-- helping evaluate inventory distribution and stock planning.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(
        AVG(stock_quantity),
        2
    ) AS average_stock_per_product

FROM inventory;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the average number of units available per
product in inventory. Monitoring this KPI helps assess
whether inventory levels are balanced across the product
catalog and supports inventory optimization decisions.
*/

-- ============================================================
-- SECTION 2: Inventory Performance Analysis
-- Queries 6–10
-- ============================================================

-- ============================================================
-- Query 06
-- KPI: Top 10 Highest Stock Products
-- ============================================================
--
-- Business Question:
-- Which products currently have the highest inventory levels?
--
-- Business Value:
-- Identifies products with the largest stock quantities,
-- helping detect potential overstock situations and optimize
-- inventory carrying costs.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    p.product_id,

    p.product_name,

    p.brand,

    i.stock_quantity,

    p.average_rating,

    ROUND(
        p.price,
        2
    ) AS selling_price

FROM inventory i

JOIN products p
ON i.product_id = p.product_id

WHERE p.is_active = TRUE

ORDER BY

    i.stock_quantity DESC,
    p.average_rating DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights products with the highest inventory levels.
Monitoring these products helps identify potential
overstock situations, reduce carrying costs, and improve
inventory optimization through targeted promotions or
inventory redistribution.
*/

-- ============================================================
-- Query 07
-- KPI: Top 10 Lowest Stock Products
-- ============================================================
--
-- Business Question:
-- Which products currently have the lowest inventory levels?
--
-- Business Value:
-- Identifies products at risk of stockouts, enabling timely
-- replenishment decisions and reducing the likelihood of
-- lost sales.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    p.product_id,

    p.product_name,

    p.brand,

    i.stock_quantity,

    i.reorder_level,

    p.average_rating,

    ROUND(
        p.price,
        2
    ) AS selling_price

FROM inventory i

JOIN products p
ON i.product_id = p.product_id

WHERE p.is_active = TRUE

ORDER BY

    i.stock_quantity ASC,
    i.reorder_level DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights products with the lowest inventory levels.
These products should be monitored closely for timely
replenishment to avoid stockouts, maintain product
availability, and minimize lost sales.
*/

-- ============================================================
-- Query 08
-- KPI: Top Categories by Inventory Value
-- ============================================================
--
-- Business Question:
-- Which product categories hold the highest inventory value?
--
-- Business Value:
-- Helps identify where the company's inventory investment
-- is concentrated, supporting inventory planning, purchasing,
-- and working capital management.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    c.category_id,

    c.category_name,

    COUNT(p.product_id) AS total_products,

    SUM(i.stock_quantity) AS total_units,

    ROUND(
        SUM(i.stock_quantity * p.price),
        2
    ) AS inventory_value

FROM inventory i

JOIN products p
ON i.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

WHERE p.is_active = TRUE

GROUP BY

    c.category_id,
    c.category_name

ORDER BY inventory_value DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Shows which product categories represent the highest
inventory investment. Categories with large inventory
values should be monitored carefully to balance product
availability while minimizing inventory carrying costs
and excess capital tied up in stock.
*/

-- ============================================================
-- Query 09
-- KPI: Products Needing Immediate Reorder
-- ============================================================
--
-- Business Question:
-- Which products require immediate replenishment because
-- their stock has fallen below the reorder level?
--
-- Business Value:
-- Helps inventory managers prioritize replenishment,
-- preventing stockouts and minimizing lost sales.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    p.product_id,

    p.product_name,

    p.brand,

    i.stock_quantity,

    i.reorder_level,

    (i.reorder_level - i.stock_quantity) AS shortage_quantity,

    ROUND(
        p.price,
        2
    ) AS selling_price

FROM inventory i

JOIN products p
ON i.product_id = p.product_id

WHERE

    p.is_active = TRUE
    AND i.stock_quantity < i.reorder_level

ORDER BY

    shortage_quantity DESC,
    i.stock_quantity ASC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights products that require immediate replenishment.
Prioritizing these products helps reduce stockouts,
maintain product availability, and improve customer
satisfaction while supporting efficient inventory planning.
*/

-- ============================================================
-- Query 10
-- KPI: Inventory Value Contribution of Top 10 Products
-- ============================================================
--
-- Business Question:
-- Which products represent the largest share of the company's
-- inventory investment, and what percentage of total inventory
-- value does each contribute?
--
-- Business Value:
-- Identifies products where the company has invested the
-- highest inventory value, helping prioritize inventory
-- optimization, working capital management, and stock
-- monitoring efforts.
--
-- SQL Difficulty:
-- Advanced (CTE + Window Functions)
-- ============================================================

WITH product_inventory_value AS (

    SELECT

        p.product_id,

        p.product_name,

        p.brand,

        i.stock_quantity,

        ROUND(
            (i.stock_quantity * p.price),
            2
        ) AS inventory_value

    FROM products p

    JOIN inventory i
        ON p.product_id = i.product_id

    WHERE p.is_active = TRUE

),

top_10 AS (

    SELECT *

    FROM product_inventory_value

    ORDER BY inventory_value DESC

    LIMIT 10

)

SELECT

    product_id,

    product_name,

    brand,

    stock_quantity,

    inventory_value,

    ROUND(

        inventory_value * 100.0 /

        (
            SELECT SUM(stock_quantity * price)
            FROM inventory i
            JOIN products p
                ON i.product_id = p.product_id
            WHERE p.is_active = TRUE
        ),

        2

    ) AS product_inventory_percentage,

    ROUND(

        SUM(inventory_value) OVER () * 100.0 /

        (
            SELECT SUM(stock_quantity * price)
            FROM inventory i
            JOIN products p
                ON i.product_id = p.product_id
            WHERE p.is_active = TRUE
        ),

        2

    ) AS top_10_inventory_percentage

FROM top_10

ORDER BY inventory_value DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Shows each product's contribution to the company's total
inventory value while also displaying the combined inventory
value contributed by the top 10 products.

A high combined contribution indicates that a significant
portion of inventory investment is concentrated in a small
number of products. These products should be monitored
closely to optimize working capital, reduce carrying costs,
and minimize the financial risk associated with excess
inventory.

The repeated Top 10 Inventory Percentage column provides
the overall contribution of the company's top 10 inventory
products without requiring a separate summary query.
*/
