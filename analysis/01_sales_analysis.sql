-- ============================================================
-- E-Commerce Analytics Project
-- Sales Performance Analysis
-- ============================================================
--
-- Objective:
-- Analyze sales performance using business-focused SQL queries.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Executive KPIs
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Revenue
-- ============================================================
--
-- Business Question:
-- What is the total revenue generated from completed
-- (delivered) orders?
--
-- Business Value:
-- Measures the total realized revenue from successfully
-- delivered orders. This KPI is commonly used by management
-- to monitor overall business performance and financial growth.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM vw_sales_completed;

/*
Expected Output

total_revenue
-------------
940952236.93

Power BI Visualization:
KPI Card

Business Insight:
Represents the total realized revenue generated from completed
customer orders.
*/

-- ============================================================
-- Query 02
-- KPI: Total Completed Orders
-- ============================================================
--
-- Business Question:
-- How many customer orders were successfully completed?
--
-- Business Value:
-- Measures the total number of delivered orders and helps
-- evaluate sales volume and business activity.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT
    COUNT(*) AS total_completed_orders
FROM vw_sales_completed;

/*
Expected Output

total_completed_orders
----------------------
19920

Power BI Visualization:
KPI Card

Business Insight:
Represents the total number of successfully delivered
customer orders.
*/

-- ============================================================
-- Query 03
-- KPI: Average Order Value (AOV)
-- ============================================================
--
-- Business Question:
-- What is the average revenue generated per completed order?
--
-- Business Value:
-- Helps evaluate customer purchasing behavior and average
-- spending per transaction.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT
    ROUND(AVG(total_revenue), 2) AS average_order_value
FROM vw_sales_completed;

/*
Expected Output

average_order_value
-------------------
47236.56

Power BI Visualization:
KPI Card

Business Insight:
A higher Average Order Value indicates customers spend
more per purchase, which may result from premium products,
effective upselling, or bundled offers.
*/

-- ============================================================
-- Query 04
-- KPI: Total Items Sold
-- ============================================================
--
-- Business Question:
-- How many individual products have been sold through
-- completed orders?
--
-- Business Value:
-- Measures product sales volume across all delivered orders.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT
    SUM(total_items) AS total_items_sold
FROM vw_sales_completed;

/*
Expected Output

total_items_sold
----------------
79907

Power BI Visualization:
KPI Card

Business Insight:
Shows the total quantity of products sold, helping evaluate
overall sales volume and customer demand.
*/

-- ============================================================
-- Query 05
-- KPI: Average Items per Order
-- ============================================================
--
-- Business Question:
-- On average, how many items does each completed order contain?
--
-- Business Value:
-- Helps understand customer purchasing patterns and basket size.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT
    ROUND(AVG(total_items), 2) AS average_items_per_order
FROM vw_sales_completed;

/*
Expected Output

average_items_per_order
-----------------------
4.01

Power BI Visualization:
KPI Card

Business Insight:
A larger average basket size may indicate successful cross-selling
or customers purchasing multiple products in a single order.
*/

-- ============================================================
-- SECTION 2: Revenue Trends
-- Queries 6–9
-- ============================================================

-- ============================================================
-- Query 06
-- KPI: Monthly Revenue Trend
-- ============================================================
--
-- Business Question:
-- How has revenue changed month by month?
--
-- Business Value:
-- Identifies seasonal trends, growth patterns, and revenue fluctuations
-- over time to support business planning.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC('month', order_date)::DATE AS month,

    ROUND(
        SUM(total_revenue),
        2
    ) AS monthly_revenue

FROM vw_sales_completed

GROUP BY month

ORDER BY month;

/*
Expected Output

month        monthly_revenue
-----------  ----------------
...

Power BI Visualization:
Line Chart

Business Insight:
Displays monthly revenue trends, helping identify seasonal demand,
growth periods, and unexpected declines.
*/

-- ============================================================
-- Query 07
-- KPI: Monthly Completed Orders
-- ============================================================
--
-- Business Question:
-- How many completed orders were placed each month?
--
-- Business Value:
-- Tracks monthly sales volume and helps evaluate customer demand.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC('month', order_date)::DATE AS month,

    COUNT(*) AS completed_orders

FROM vw_sales_completed

GROUP BY month

ORDER BY month;

/*
Power BI Visualization:
Line Chart

Business Insight:
Shows whether changes in revenue are driven by order volume or
by changes in average order value.
*/

-- ============================================================
-- Query 08
-- KPI: Monthly Average Order Value

-- Business Question:
-- How has the average order value changed month by month?
--
-- Business Value:
-- Tracks customer spending patterns over time and helps
-- identify periods of higher or lower average purchase value.
-- This KPI is useful for evaluating pricing strategies,
-- promotional campaigns, and upselling effectiveness.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC('month', order_date)::DATE AS month,

    ROUND(
        AVG(total_revenue),
        2
    ) AS average_order_value

FROM vw_sales_completed

GROUP BY month

ORDER BY month;

/*
Power BI Visualization:
Line Chart

Business Insight:
Helps determine whether customers are spending more or less
per order over time.
*/

-- ============================================================
-- Query 09
-- KPI: Monthly Revenue Growth Rate (%)
-- ============================================================
--
-- Business Question:
-- How has monthly revenue changed compared to the previous month?
--
-- Business Value:
-- Measures month-over-month growth to identify business trends,
-- seasonal patterns, and periods of strong or weak performance.
--
-- SQL Difficulty:
-- Intermediate (Window Function)
-- ============================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(total_revenue) AS monthly_revenue

    FROM vw_sales_completed

    GROUP BY month

)

SELECT

    month,

    ROUND(monthly_revenue,2) AS monthly_revenue,

    ROUND(

        LAG(monthly_revenue)
        OVER(ORDER BY month)

    ,2) AS previous_month_revenue,

    ROUND(

        (
            (monthly_revenue -
            LAG(monthly_revenue)
            OVER(ORDER BY month))
            /
            LAG(monthly_revenue)
            OVER(ORDER BY month)
        ) * 100

    ,2) AS mom_growth_percentage

FROM monthly_sales

ORDER BY month;

/*
Power BI Visualization:
Line Chart with Growth %

Business Insight:
Positive percentages indicate business growth,
while negative percentages highlight months where
sales declined compared to the previous month.
*/

-- ============================================================
-- SECTION 3: Geographic Sales Analysis
-- Queries 10–15
-- ============================================================

-- ============================================================
-- Query 10
-- KPI: Revenue by State
-- ============================================================
--
-- Business Question:
-- Which states generate the highest revenue from completed orders?
--
-- Business Value:
-- Helps identify high-performing markets, supports regional
-- sales strategy, marketing investment, and expansion planning.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    state,

    COUNT(*) AS completed_orders,

    SUM(total_items) AS total_items_sold,

    ROUND(SUM(total_revenue), 2) AS total_revenue,

    ROUND(AVG(total_revenue), 2) AS average_order_value

FROM vw_sales_completed

GROUP BY state

ORDER BY total_revenue DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Ranks states by revenue generated from completed orders,
helping identify the company's strongest regional markets.
*/

-- ============================================================
-- Query 11
-- KPI: Revenue by City
-- ============================================================
--
-- Business Question:
-- Which cities generate the highest revenue from completed orders?
--
-- Business Value:
-- Identifies high-performing cities to support regional
-- marketing, sales planning, and expansion strategies.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    city,

    state,

    COUNT(*) AS completed_orders,

    SUM(total_items) AS total_items_sold,

    ROUND(SUM(total_revenue), 2) AS total_revenue,

    ROUND(AVG(total_revenue), 2) AS average_order_value

FROM vw_sales_completed

GROUP BY city, state

ORDER BY total_revenue DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Ranks cities by revenue generated from completed orders,
helping identify the company's strongest local markets.
*/

-- ============================================================
-- Query 12
-- KPI: Top 10 Cities by Revenue
-- ============================================================
--
-- Business Question:
-- Which 10 cities generate the highest revenue from completed
-- orders?
--
-- Business Value:
-- Identifies the company's strongest local markets for
-- marketing campaigns, expansion, and sales strategy.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    city,

    state,

    COUNT(*) AS completed_orders,

    SUM(total_items) AS total_items_sold,

    ROUND(SUM(total_revenue), 2) AS total_revenue,

    ROUND(AVG(total_revenue), 2) AS average_order_value

FROM vw_sales_completed

GROUP BY city, state

ORDER BY total_revenue DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Highlights the company's top-performing cities by revenue,
helping management focus on high-value regional markets.
*/

-- ============================================================
-- Query 13
-- KPI: Bottom 10 Cities by Revenue
-- ============================================================
--
-- Business Question:
-- Which cities generate the lowest revenue from completed
-- orders?
--
-- Business Value:
-- Helps identify underperforming markets that may require
-- operational improvements, targeted promotions, or
-- strategic evaluation.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    city,

    state,

    COUNT(*) AS completed_orders,

    SUM(total_items) AS total_items_sold,

    ROUND(SUM(total_revenue), 2) AS total_revenue,

    ROUND(AVG(total_revenue), 2) AS average_order_value

FROM vw_sales_completed

GROUP BY city, state

ORDER BY total_revenue ASC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Identifies cities with the lowest revenue contribution,
allowing businesses to investigate demand, logistics,
competition, or marketing opportunities.
*/

-- ============================================================
-- Query 14
-- KPI: Revenue by Order Source
-- ============================================================
--
-- Business Question:
-- Which sales channel generates the highest revenue?
--
-- Business Value:
-- Compares Website and Mobile App performance to support
-- marketing investment and platform optimization decisions.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    order_source,

    COUNT(*) AS completed_orders,

    SUM(total_items) AS total_items_sold,

    ROUND(SUM(total_revenue), 2) AS total_revenue,

    ROUND(AVG(total_revenue), 2) AS average_order_value

FROM vw_sales_completed

GROUP BY order_source

ORDER BY total_revenue DESC;

/*
Power BI Visualization:
Donut Chart or Clustered Column Chart

Business Insight:
Shows the contribution of each sales channel to overall
revenue and order volume, helping evaluate channel performance.
*/

-- ============================================================
-- Query 15
-- KPI: Revenue by Payment Method
-- ============================================================
--
-- Business Question:
-- Which payment methods generate the highest revenue?
--
-- Business Value:
-- Helps understand customer payment preferences and supports
-- payment gateway optimization, promotional campaigns,
-- and strategic partnerships with payment providers.
--
-- SQL Difficulty:
-- Intermediate–Advanced
-- ============================================================

SELECT

    payment_method,

    COUNT(*) AS completed_orders,

    SUM(total_items) AS total_items_sold,

    ROUND(SUM(total_revenue), 2) AS total_revenue,

    ROUND(AVG(total_revenue), 2) AS average_order_value,

    ROUND(
        SUM(total_revenue) * 100.0 /
        SUM(SUM(total_revenue)) OVER (),
        2
    ) AS revenue_percentage

FROM vw_sales_completed

GROUP BY payment_method

ORDER BY total_revenue DESC;

/*
===============================================================
Power BI Visualization:
Clustered Bar Chart or Donut Chart

Business Insight:
Shows customer payment preferences and the revenue contribution
of each payment method. Useful for optimizing payment gateway
partnerships, promotional offers, and improving checkout
experience.
===============================================================
*/

/*
===============================================================
Sales Performance Analysis Summary

Views Used:
✔ vw_sales_completed

Queries:
15

KPIs Covered:
✔ Executive KPIs
✔ Revenue Trends
✔ Geographic Analysis
✔ Sales Channel Analysis
✔ Payment Analysis

Techniques Used:
✔ Aggregate Functions
✔ GROUP BY
✔ ORDER BY
✔ DATE_TRUNC
✔ CTE
✔ Window Functions
✔ LAG()

===============================================================
*/