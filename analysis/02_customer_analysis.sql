-- ============================================================
-- E-Commerce Analytics Project
-- Customer Analysis
-- ============================================================
--
-- Objective:
-- Analyze customer behavior, purchasing patterns, and customer
-- value using business-focused SQL queries.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Customer KPIs
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Customers
-- ============================================================
--
-- Business Question:
-- How many unique customers have placed completed orders?
--
-- Business Value:
-- Measures the size of the active customer base that has
-- successfully completed purchases.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(DISTINCT customer_id) AS total_customers

FROM vw_sales_completed;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the total number of customers who have
successfully completed at least one purchase.
*/

-- ============================================================
-- Query 02
-- KPI: Repeat Customers
-- ============================================================
--
-- Business Question:
-- How many customers have placed more than one completed order?
--
-- Business Value:
-- Measures customer retention and loyalty by identifying
-- customers who returned to make additional purchases.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    COUNT(*) AS repeat_customers

FROM (

    SELECT

        customer_id

    FROM vw_sales_completed

    GROUP BY customer_id

    HAVING COUNT(order_id) > 1

) AS repeat_customer_list;

/*
Power BI Visualization:
KPI Card

Business Insight:
A higher number of repeat customers generally indicates
strong customer satisfaction, loyalty, and retention.
*/

-- ============================================================
-- Query 03
-- KPI: One-Time Customers
-- ============================================================
--
-- Business Question:
-- How many customers placed only one completed order?
--
-- Business Value:
-- Identifies customers who have not returned after their
-- first purchase, helping evaluate customer retention
-- opportunities.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    COUNT(*) AS one_time_customers

FROM (

    SELECT

        customer_id

    FROM vw_sales_completed

    GROUP BY customer_id

    HAVING COUNT(order_id) = 1

) AS one_time_customer_list;

/*
Power BI Visualization:
KPI Card

Business Insight:
A high number of one-time customers may indicate
opportunities to improve customer retention through
loyalty programs, personalized offers, or remarketing.
*/

-- ============================================================
-- Query 04
-- KPI: Repeat Customer Rate (%)
-- ============================================================
--
-- Business Question:
-- What percentage of customers are repeat customers?
--
-- Business Value:
-- Measures customer retention by showing the proportion
-- of customers who made more than one completed purchase.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

WITH customer_orders AS (

    SELECT
        customer_id,
        COUNT(order_id) AS total_orders

    FROM vw_sales_completed

    GROUP BY customer_id

)

SELECT

    ROUND(

        COUNT(*) FILTER (WHERE total_orders > 1)
        * 100.0
        / COUNT(*)

    ,2) AS repeat_customer_rate

FROM customer_orders;

/*
Power BI Visualization:
KPI Card

Business Insight:
A higher repeat customer rate indicates stronger customer
loyalty and retention.
*/

-- ============================================================
-- Query 05
-- KPI: Average Orders per Customer
-- ============================================================
--
-- Business Question:
-- On average, how many completed orders does each customer place?
--
-- Business Value:
-- Measures customer purchasing frequency and overall engagement.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        COUNT(order_id)::NUMERIC
        /
        COUNT(DISTINCT customer_id)::NUMERIC

    ,2) AS average_orders_per_customer

FROM vw_sales_completed;

/*
Power BI Visualization:
KPI Card

Business Insight:
A higher value indicates customers purchase more frequently,
which generally reflects stronger engagement and loyalty.
*/

-- ============================================================
-- SECTION 2: Customer Value Analysis
-- Queries 6–10
-- ============================================================

-- ============================================================
-- Query 06
-- KPI: Top 10 Customers by Lifetime Revenue
-- ============================================================
--
-- Business Question:
-- Which customers have generated the highest lifetime revenue?
--
-- Business Value:
-- Identifies high-value customers for loyalty programs,
-- personalized marketing, and premium customer engagement.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    customer_id,

    customer_name,

    city,

    state,

    COUNT(order_id) AS completed_orders,

    SUM(total_items) AS total_items_purchased,

    ROUND(
        SUM(total_revenue),
        2
    ) AS lifetime_revenue,

    ROUND(
        AVG(total_revenue),
        2
    ) AS average_order_value

FROM vw_sales_completed

GROUP BY

    customer_id,
    customer_name,
    city,
    state

ORDER BY lifetime_revenue DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights the company's most valuable customers based on
their total lifetime revenue, helping prioritize retention
strategies and personalized engagement.
*/

-- ============================================================
-- Query 07
-- KPI: Average Customer Lifetime Value
-- ============================================================
--
-- Business Question:
-- What is the average lifetime revenue generated per customer?
--
-- Business Value:
-- Measures the average revenue contributed by each customer,
-- helping evaluate overall customer value and acquisition
-- strategies.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

WITH customer_lifetime_value AS (

    SELECT

        customer_id,

        SUM(total_revenue) AS lifetime_revenue

    FROM vw_sales_completed

    GROUP BY customer_id

)

SELECT

    ROUND(
        AVG(lifetime_revenue),
        2
    ) AS average_customer_lifetime_value

FROM customer_lifetime_value;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the average revenue generated by each customer
across all completed purchases. A higher value indicates
customers contribute more revenue over their lifetime.
*/

-- ============================================================
-- Query 08
-- KPI: Top Customers by Number of Orders
-- ============================================================
--
-- Business Question:
-- Which customers have placed the highest number of completed
-- orders?
--
-- Business Value:
-- Identifies the most loyal and frequently purchasing customers,
-- supporting loyalty programs and customer retention strategies.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    customer_id,

    customer_name,

    city,

    state,

    COUNT(order_id) AS completed_orders,

    ROUND(
        SUM(total_revenue),
        2
    ) AS lifetime_revenue,

    ROUND(
        AVG(total_revenue),
        2
    ) AS average_order_value

FROM vw_sales_completed

GROUP BY

    customer_id,
    customer_name,
    city,
    state

ORDER BY completed_orders DESC,
         lifetime_revenue DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights customers who purchase most frequently. These
customers are valuable candidates for loyalty rewards,
exclusive offers, and personalized engagement.
*/

-- ============================================================
-- Query 09
-- KPI: Top Customers by Quantity Purchased
-- ============================================================
--
-- Business Question:
-- Which customers have purchased the highest number of items?
--
-- Business Value:
-- Identifies customers with the largest purchase volumes,
-- helping businesses target bulk buyers, loyal shoppers,
-- and high-demand customer segments.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    customer_id,

    customer_name,

    city,

    state,

    SUM(total_items) AS total_items_purchased,

    COUNT(order_id) AS completed_orders,

    ROUND(
        SUM(total_revenue),
        2
    ) AS lifetime_revenue

FROM vw_sales_completed

GROUP BY

    customer_id,
    customer_name,
    city,
    state

ORDER BY

    total_items_purchased DESC,
    lifetime_revenue DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Identifies customers purchasing the highest number of
products, helping businesses recognize bulk buyers and
design targeted promotions or loyalty rewards.
*/

-- ============================================================
-- Query 10
-- KPI: Revenue Contribution of Top 10 Customers
-- ============================================================
--
-- Business Question:
-- How much revenue do the company's top 10 customers
-- contribute, and what is each customer's share?
--
-- Business Value:
-- Helps identify whether revenue is concentrated among a
-- small group of high-value customers, supporting customer
-- retention and strategic account management.
--
-- SQL Difficulty:
-- Advanced (CTE + Window Functions)
-- ============================================================

WITH customer_revenue AS (

    SELECT

        customer_id,
        customer_name,
        city,
        state,

            ROUND(
                SUM(total_revenue),
                2
            ) AS lifetime_revenue
        
    FROM vw_sales_completed

    GROUP BY

        customer_id,
        customer_name,
        city,
        state

),

top_10 AS (

    SELECT *

    FROM customer_revenue

    ORDER BY lifetime_revenue DESC

    LIMIT 10

)

SELECT

    customer_id,

    customer_name,

    city,

    state,

    lifetime_revenue,

    ROUND(
        lifetime_revenue * 100.0 /
        (
            SELECT SUM(total_revenue)
            FROM vw_sales_completed
        ),
        2
    ) AS customer_revenue_percentage,

    ROUND(
        SUM(lifetime_revenue) OVER () * 100.0 /
        (
            SELECT SUM(total_revenue)
            FROM vw_sales_completed
        ),
        2
    ) AS top_10_revenue_percentage

FROM top_10

ORDER BY lifetime_revenue DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Shows each top customer's contribution to total company
revenue while also displaying the combined revenue share
of the top 10 customers.

A high combined contribution indicates that revenue is
concentrated among a small group of customers, suggesting
these customers should be prioritized through retention,
loyalty programs, and personalized engagement.

The repeated Top 10 Revenue Percentage column provides
the overall contribution of the company's top 10 customers
without requiring a separate summary query.
*/