-- ============================================================
-- E-Commerce Analytics Project
-- Shipping Analysis
-- ============================================================
--
-- Objective:
-- Analyze shipment performance, delivery efficiency,
-- shipping costs, courier performance, warehouse
-- operations, and customer delivery experience to
-- identify opportunities for improving logistics
-- efficiency, reducing delivery delays, and enhancing
-- customer satisfaction.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Shipping KPIs
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Shipments
-- ============================================================
--
-- Business Question:
-- How many shipments have been processed?
--
-- Business Value:
-- Measures the total number of shipments processed across
-- the logistics network, providing a high-level view of
-- shipping activity and operational workload.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS total_shipments

FROM shipments;

/*
Power BI Visualization:
KPI Card

Business Insight:
A total of 25,000 shipments have been processed across the
logistics network. Monitoring shipment volume helps
evaluate logistics activity, operational capacity, and
serves as the foundation for analyzing delivery
performance, shipping costs, and overall shipping
efficiency.
*/

-- ============================================================
-- Query 02
-- KPI: Delivery Status Distribution
-- ============================================================
--
-- Business Question:
-- What is the distribution of shipments across different
-- delivery statuses?
--
-- Business Value:
-- Measures the operational status of all shipments by
-- identifying how many orders have been delivered, are
-- currently in transit, delayed, or returned. This KPI
-- helps monitor logistics performance and operational
-- efficiency.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    delivery_status,

    COUNT(*) AS total_shipments,

    ROUND(

        COUNT(*) * 100.0
        /
        SUM(COUNT(*)) OVER(),

        2

    ) AS shipment_percentage

FROM shipments

GROUP BY

    delivery_status

ORDER BY

    total_shipments DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:
Out of 25,000 shipments processed, 22,470 shipments
(89.88%) were successfully delivered, indicating a
strong overall delivery performance. Meanwhile, 5.00%
of shipments remain in transit, 3.13% experienced
delivery delays, and 1.99% were returned. Monitoring
these metrics helps identify operational bottlenecks,
improve delivery reliability, and enhance customer
satisfaction.
*/

-- ============================================================
-- Query 03
-- KPI: On-Time Delivery Rate
-- ============================================================
--
-- Business Question:
-- What percentage of shipments were delivered on time?
--
-- Business Value:
-- Measures the proportion of shipments delivered within
-- the expected delivery timeline. This KPI is one of the
-- most important indicators of logistics performance and
-- customer service quality, helping evaluate delivery
-- reliability and operational efficiency.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        COUNT(*)
        FILTER (
            WHERE on_time_delivery = TRUE
        ) * 100.0
        /

        COUNT(*)
        FILTER (
            WHERE delivery_status = 'Delivered'),

        2

    ) AS on_time_delivery_rate

FROM shipments;

/*
Power BI Visualization:
KPI Card

Business Insight:
Out of all successfully delivered shipments, 80.06% were
delivered on or before the expected delivery date. This
indicates a strong level of logistics reliability, while
the remaining deliveries present opportunities to improve
courier performance, route optimization, and overall
customer experience.
*/

-- ============================================================
-- Query 04
-- KPI: Average Shipping Cost
-- ============================================================
--
-- Business Question:
-- What is the average shipping cost per shipment?
--
-- Business Value:
-- Measures the average logistics cost incurred for each
-- shipment. This KPI helps evaluate shipping cost
-- efficiency, monitor logistics expenses, and support
-- cost optimization strategies.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost

FROM shipments;

/*
Power BI Visualization:
KPI Card

Business Insight:
The average shipping cost per shipment is ₹144.58,
providing a benchmark for evaluating logistics expenses
across the business. Monitoring this KPI helps identify
cost optimization opportunities, improve shipping
efficiency, and support better supply chain and courier
management decisions.
*/

-- ============================================================
-- Query 05
-- KPI: Average Shipping Distance
-- ============================================================
--
-- Business Question:
-- What is the average shipping distance covered per shipment?
--
-- Business Value:
-- Measures the average distance traveled to deliver customer
-- orders. This KPI helps evaluate the geographical reach of
-- the logistics network, optimize transportation planning,
-- and improve overall delivery efficiency.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        AVG(shipping_distance_km),

        2

    ) AS average_shipping_distance_km

FROM shipments;

/*
Power BI Visualization:
KPI Card

Business Insight:
The average shipping distance per shipment is 1,256.19 km,
reflecting the geographical reach of the company's logistics
network. Monitoring this KPI helps optimize transportation
routes, evaluate distribution efficiency, reduce logistics
costs, and support strategic warehouse and courier planning.
*/

-- ============================================================
-- SECTION 2: Shipping Performance Analysis
-- Queries 6–10
-- ============================================================

-- ============================================================
-- Query 06
-- KPI: Courier Partner Performance
-- ============================================================
--
-- Business Question:
-- How does each courier partner perform in terms of
-- shipment volume, delivery reliability, shipping costs,
-- and customer satisfaction?
--
-- Business Value:
-- Compares courier partners across key logistics
-- performance metrics to support vendor evaluation,
-- contract negotiations, cost optimization, and service
-- quality improvement.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    courier_partner,

    COUNT(*) AS total_shipments,

    COUNT(*)
    FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE on_time_delivery = TRUE
        ) * 100.0

        /

        COUNT(*)
        FILTER (
            WHERE delivery_status = 'Delivered'
        ),

        2

    ) AS on_time_delivery_rate,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating

FROM shipments

GROUP BY

    courier_partner

ORDER BY

    on_time_delivery_rate DESC,

    average_delivery_rating DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Ekart achieved the highest on-time delivery rate (81.40%),
while XpressBees received the highest average customer
delivery rating (4.31). Shipping costs remained highly
consistent across all courier partners, averaging around
₹144–₹145 per shipment, indicating balanced logistics
pricing. Overall, the analysis enables the business to
benchmark courier performance, optimize vendor selection,
and improve delivery reliability.
*/

-- ============================================================
-- Query 07
-- KPI: Delivery Mode Performance
-- ============================================================
--
-- Business Question:
-- How does each delivery mode perform in terms of
-- shipment volume, delivery reliability, shipping costs,
-- and customer satisfaction?
--
-- Business Value:
-- Compares delivery modes across key logistics
-- performance metrics to evaluate service efficiency,
-- optimize delivery offerings, and support decisions
-- related to pricing, customer experience, and
-- operational planning.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    delivery_mode,

    COUNT(*) AS total_shipments,

    COUNT(*)
    FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE on_time_delivery = TRUE
        ) * 100.0

        /

        COUNT(*)
        FILTER (
            WHERE delivery_status = 'Delivered'
        ),

        2

    ) AS on_time_delivery_rate,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating

FROM shipments

GROUP BY

    delivery_mode

ORDER BY

    on_time_delivery_rate DESC,

    average_delivery_rating DESC;

/*
Power BI Visualization:
Clustered Bar Chart

Business Insight:
Next Day delivery achieved the highest on-time delivery
rate (80.41%), while Standard delivery handled the largest
shipment volume (16,195 shipments) with a strong on-time
performance of 80.28%. Customer satisfaction remained
consistently high across all delivery modes, with average
delivery ratings around 4.28–4.30. The analysis indicates
that all delivery modes maintain comparable service
quality, enabling the business to balance delivery speed,
operational efficiency, and logistics costs based on
customer requirements.
*/

-- ============================================================
-- Query 08
-- KPI: Warehouse Performance
-- ============================================================
--
-- Business Question:
-- How does each warehouse perform in terms of shipment
-- volume, delivery reliability, shipping costs, and
-- customer satisfaction?
--
-- Business Value:
-- Evaluates warehouse performance across key logistics
-- metrics to identify operational strengths, improve
-- distribution efficiency, and support warehouse
-- optimization decisions.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    warehouse_location,

    COUNT(*) AS total_shipments,

    COUNT(*)
    FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE on_time_delivery = TRUE
        ) * 100.0

        /

        COUNT(*)
        FILTER (
            WHERE delivery_status = 'Delivered'
        ),

        2

    ) AS on_time_delivery_rate,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating

FROM shipments

GROUP BY

    warehouse_location

ORDER BY

    on_time_delivery_rate DESC,

    average_delivery_rating DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Ahmedabad Warehouse achieved the highest on-time delivery
rate (81.67%), while Mumbai Warehouse processed the
largest shipment volume (3,308 shipments). Customer
delivery ratings remained consistently high across all
warehouses, ranging from 4.27 to 4.30, indicating a
uniform customer experience throughout the logistics
network. Shipping costs also remained relatively stable,
averaging between ₹143 and ₹146 per shipment, suggesting
efficient cost management across distribution centers.
*/

-- ============================================================
-- Query 09
-- KPI: Delivery City Performance
-- ============================================================
--
-- Business Question:
-- How does shipment performance vary across delivery cities?
--
-- Business Value:
-- Evaluates delivery performance across different cities by
-- comparing shipment volume, delivery reliability, shipping
-- costs, and customer satisfaction. This analysis helps
-- identify high-performing markets, optimize regional
-- logistics operations, and improve customer service.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    delivery_city,

    COUNT(*) AS total_shipments,

    COUNT(*)
    FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE on_time_delivery = TRUE
        ) * 100.0

        /

        COUNT(*)
        FILTER (
            WHERE delivery_status = 'Delivered'
        ),

        2

    ) AS on_time_delivery_rate,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating

FROM shipments

GROUP BY

    delivery_city

ORDER BY

    on_time_delivery_rate DESC,

    average_delivery_rating DESC;

/*
Power BI Visualization:
Filled Map / Horizontal Bar Chart

Business Insight:
Pune achieved the highest on-time delivery rate (81.90%),
while Chennai processed the highest shipment volume (2,545
shipments). Customer delivery ratings remained consistently
high across all cities, ranging from 4.24 to 4.30,
indicating a positive customer experience throughout the
delivery network. Shipping costs were also relatively
consistent, averaging between ₹143 and ₹147 per shipment,
suggesting efficient logistics operations across different
regions.
*/

-- ============================================================
-- Query 10
-- KPI: Delivery Attempt Analysis
-- ============================================================
--
-- Business Question:
-- How efficiently are shipments delivered based on the
-- number of delivery attempts?
--
-- Business Value:
-- Evaluates delivery efficiency by analyzing how many
-- shipments require multiple delivery attempts. This KPI
-- helps identify operational inefficiencies, reduce
-- redelivery costs, and improve first-attempt delivery
-- success.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    delivery_attempts,

    COUNT(*) AS total_shipments,

    ROUND(

        COUNT(*) * 100.0

        /

        SUM(COUNT(*)) OVER(),

        2

    ) AS shipment_percentage,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating

FROM shipments

GROUP BY

    delivery_attempts

ORDER BY

    delivery_attempts;

/*
Power BI Visualization:
Column Chart

Business Insight:
The majority of shipments (81.42%) were successfully
delivered on the first attempt, demonstrating strong
last-mile delivery efficiency. Only 10.85% required a
second attempt, while just 2.73% needed three delivery
attempts. Customer satisfaction declined as delivery
attempts increased, with average delivery ratings dropping
from 4.33 after a first-attempt delivery to 3.59 after
three attempts. These insights highlight the importance
of improving first-attempt delivery success to enhance
customer experience and reduce operational costs.
*/

-- ============================================================
-- SECTION 3: Operational Insights & Trends
-- Queries 11–15
-- ============================================================

-- ============================================================
-- Query 11
-- KPI: Monthly Shipment Trend
-- ============================================================
--
-- Business Question:
-- How has shipment volume changed month by month?
--
-- Business Value:
-- Tracks shipment volume over time to identify seasonal
-- demand patterns, operational workload, and long-term
-- logistics growth trends.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC(
        'month',
        shipment_date
    )::DATE AS month,

    COUNT(*) AS total_shipments,

    COUNT(*)
    FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost

FROM shipments

GROUP BY

    month

ORDER BY

    month;

/*
Power BI Visualization:
Line Chart

Business Insight:
Shipment volume remained relatively stable throughout the
analysis period, generally ranging between 500 and 625
shipments per month. Peak shipment activity occurred during
April 2025 and March 2026 (625 shipments), while July 2026
recorded the lowest shipment volume (500 shipments).
Delivered shipments closely followed the overall shipment
trend, indicating consistent logistics performance.
Average shipping costs remained stable between ₹140 and
₹150 per shipment, reflecting effective cost control
despite fluctuations in shipment volume.
*/

-- ============================================================
-- Query 12
-- KPI: Monthly On-Time Delivery Trend
-- ============================================================
--
-- Business Question:
-- How has the on-time delivery rate changed month by month?
--
-- Business Value:
-- Monitors delivery reliability over time by tracking the
-- percentage of shipments delivered on or before the
-- estimated delivery date. This KPI helps identify
-- operational improvements, seasonal challenges, and
-- opportunities to enhance customer satisfaction.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC(
        'month',
        shipment_date
    )::DATE AS month,

    COUNT(*)
    FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    COUNT(*)
    FILTER (
        WHERE on_time_delivery = TRUE
    ) AS on_time_deliveries,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE on_time_delivery = TRUE
        ) * 100.0

        /

        COUNT(*)
        FILTER (
            WHERE delivery_status = 'Delivered'
        ),

        2

    ) AS on_time_delivery_rate

FROM shipments

GROUP BY

    month

ORDER BY

    month;

/*
Power BI Visualization:
Line Chart

Business Insight:
The monthly on-time delivery rate remained relatively
stable throughout the analysis period, generally ranging
between 78% and 84%. The highest on-time delivery rate
was achieved in February 2026 (83.61%), while June 2025
recorded the lowest performance (77.55%). Despite minor
seasonal fluctuations, the consistently high delivery
performance demonstrates a reliable logistics network and
effective last-mile delivery operations, contributing to
a positive customer experience.
*/

-- ============================================================
-- Query 13
-- KPI: Delay Reason Analysis
-- ============================================================
--
-- Business Question:
-- What are the most common reasons for delayed shipments?
--
-- Business Value:
-- Identifies the primary causes of shipment delays,
-- enabling the business to address operational bottlenecks,
-- improve delivery reliability, and enhance customer
-- satisfaction.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    delay_reason,

    COUNT(*) AS delayed_shipments,

    ROUND(

        COUNT(*) * 100.0

        /

        SUM(COUNT(*)) OVER(),

        2

    ) AS percentage_of_delays,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating

FROM shipments

WHERE

    delivery_status = 'Delayed'

GROUP BY

    delay_reason

ORDER BY

    delayed_shipments DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Traffic was the leading cause of shipment delays,
accounting for 21.84% of all delayed deliveries, followed
closely by Warehouse Delay (21.20%) and Courier Issue
(19.41%). Delays caused by Customer Unavailable resulted
in the highest average shipping cost (₹154.30), while
Courier Issue received the highest average customer
delivery rating (2.87) among delayed shipments. The
analysis highlights that both transportation and warehouse
operations contribute significantly to delivery delays,
providing clear opportunities to improve logistics
efficiency and customer satisfaction.
*/

-- ============================================================
-- Query 14
-- KPI: Shipping Cost by Delivery Mode
-- ============================================================
--
-- Business Question:
-- How do shipping costs, delivery distance, and customer
-- satisfaction vary across different delivery modes?
--
-- Business Value:
-- Compares delivery modes based on logistics costs,
-- shipping distance, and customer satisfaction to evaluate
-- the operational efficiency and value of each delivery
-- service. This analysis supports pricing strategies,
-- service optimization, and resource allocation.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    delivery_mode,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost,

    ROUND(

        AVG(shipping_distance_km),

        2

    ) AS average_shipping_distance,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating,

    COUNT(*) AS total_shipments

FROM shipments

GROUP BY

    delivery_mode

ORDER BY

    average_shipping_cost DESC;

/*
Power BI Visualization:
Clustered Bar Chart

Business Insight:
Standard delivery handled the highest shipment volume
(16,195 shipments) and also recorded the highest average
shipping cost (₹145.16), reflecting its widespread use
across the logistics network. Customer satisfaction
remained consistently high across all delivery modes,
with average delivery ratings ranging from 4.28 to 4.30.
Average shipping distances were also highly consistent,
indicating that delivery mode selection has minimal impact
on shipping distance and overall customer experience.
*/

-- ============================================================
-- Query 15
-- KPI: Courier Partner Performance Summary
-- ============================================================
--
-- Business Question:
-- Which courier partners deliver the best overall
-- operational performance and customer experience?
--
-- Business Value:
-- Compares courier partners using key logistics
-- performance indicators, including shipment volume,
-- on-time delivery, customer satisfaction, and shipping
-- cost. This analysis helps identify high-performing
-- logistics partners and supports vendor evaluation,
-- contract negotiations, and service improvement.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    courier_partner,

    COUNT(*) AS total_shipments,

    COUNT(*)
    FILTER (
        WHERE delivery_status = 'Delivered'
    ) AS delivered_shipments,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE on_time_delivery = TRUE
        ) * 100.0

        /

        COUNT(*)
        FILTER (
            WHERE delivery_status = 'Delivered'
        ),

        2

    ) AS on_time_delivery_rate,

    ROUND(

        AVG(delivery_rating),

        2

    ) AS average_delivery_rating,

    ROUND(

        AVG(shipping_cost),

        2

    ) AS average_shipping_cost

FROM shipments

GROUP BY

    courier_partner

ORDER BY

    average_delivery_rating DESC,
    on_time_delivery_rate DESC,
    delivered_shipments DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
XpressBees achieved the highest customer satisfaction with
an average delivery rating of 4.31, while Ekart recorded
the strongest on-time delivery performance (81.40%).
Delhivery processed the highest shipment volume (4,235
shipments) and the greatest number of delivered shipments
(3,831), demonstrating its operational capacity. Average
shipping costs remained highly consistent across all
courier partners, ranging from ₹143.78 to ₹145.27,
indicating comparable logistics efficiency throughout the
delivery network.
*/

