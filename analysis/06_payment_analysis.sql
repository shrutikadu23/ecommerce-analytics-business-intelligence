-- ============================================================
-- E-Commerce Analytics Project
-- Payment Analysis
-- ============================================================
--
-- Objective:
-- Analyze payment transactions, payment success rates,
-- customer payment preferences, gateway performance,
-- processing costs, and refund trends to identify
-- opportunities for improving payment efficiency,
-- reducing transaction failures, and optimizing
-- revenue collection.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Payment Overview & Key Metrics
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Payment Transactions
-- ============================================================
--
-- Business Question:
-- How many payment transactions have been processed?
--
-- Business Value:
-- Measures the total number of payment transactions
-- processed by the platform. This KPI provides a
-- high-level overview of payment activity and serves
-- as the foundation for evaluating payment operations
-- and transaction growth.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS total_payment_transactions

FROM payments;

/*
Power BI Visualization:
KPI Card

Business Insight:
Represents the total number of payment transactions
processed on the platform. This KPI serves as the
baseline for evaluating payment activity and supports
subsequent analysis of payment success rates, gateway
performance, refund trends, and overall payment
operations.
*/

-- ============================================================
-- Query 02
-- KPI: Payment Status Distribution
-- ============================================================
--
-- Business Question:
-- How are payment transactions distributed across different
-- payment statuses?
--
-- Business Value:
-- Provides a breakdown of payment transactions by status,
-- helping monitor payment completion, pending transactions,
-- failures, and refunds. This KPI enables the business to
-- evaluate the overall health and efficiency of the payment
-- process.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    payment_status,

    COUNT(*) AS total_transactions,

    ROUND(

        COUNT(*) * 100.0 /

        SUM(COUNT(*)) OVER(),

        2

    ) AS transaction_percentage

FROM payments

GROUP BY

    payment_status

ORDER BY

    total_transactions DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:
Displays the distribution of payment transactions across
different payment statuses. A higher proportion of completed
payments indicates a reliable payment process, while an
increase in pending, failed, or refunded transactions may
highlight payment gateway issues, operational inefficiencies,
or customer checkout challenges requiring further
investigation.
*/

-- ============================================================
-- Query 03
-- KPI: Overall Payment Success Rate
-- ============================================================
--
-- Business Question:
-- What percentage of payment transactions are successfully
-- completed?
--
-- Business Value:
-- Measures the overall payment success rate across all
-- payment transactions. This KPI evaluates the reliability
-- of the payment system and helps identify issues affecting
-- successful payment processing.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    ROUND(

        COUNT(*)
        FILTER (
            WHERE payment_status = 'Completed'
        ) * 100.0 /

        COUNT(*),

        2

    ) AS payment_success_rate

FROM payments;

/*
Power BI Visualization:
KPI Card

Business Insight:
The platform maintains an excellent payment success rate of
94.14%, indicating that the vast majority of payment
attempts are completed successfully. Maintaining a high
success rate improves customer satisfaction, minimizes
checkout abandonment, and ensures efficient revenue
collection.
*/

-- ============================================================
-- Query 04
-- KPI: Payment Method Distribution
-- ============================================================
--
-- Business Question:
-- Which payment methods are most frequently used by customers?
--
-- Business Value:
-- Identifies customer payment preferences across available
-- payment methods. Understanding payment method adoption
-- helps optimize the checkout experience, prioritize payment
-- integrations, and support strategic partnerships with
-- payment providers.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    payment_method,

    COUNT(*) AS total_transactions,

    ROUND(

        COUNT(*) * 100.0 /

        SUM(COUNT(*)) OVER(),

        2

    ) AS transaction_percentage

FROM payments

GROUP BY

    payment_method

ORDER BY

    total_transactions DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
UPI is the most preferred payment method, accounting for
34.83% of all transactions, followed by Credit Card
payments at 25.03%. Digital payment methods collectively
dominate customer purchases, while Cash on Delivery
accounts for only 4.72% of transactions, indicating strong
customer adoption of online payment options and a mature
digital payment ecosystem.
*/

-- ============================================================
-- Query 05
-- KPI: Payment Gateway Distribution
-- ============================================================
--
-- Business Question:
-- Which payment gateways process the highest number of
-- payment transactions?
--
-- Business Value:
-- Identifies the distribution of transactions across payment
-- gateways, helping evaluate gateway utilization, dependency,
-- and operational load. This KPI supports gateway management
-- and payment infrastructure planning.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    gateway_name,

    COUNT(*) AS total_transactions,

    ROUND(

        COUNT(*) * 100.0 /

        SUM(COUNT(*)) OVER(),

        2

    ) AS transaction_percentage

FROM payments

GROUP BY

    gateway_name

ORDER BY

    total_transactions DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Razorpay is the primary payment gateway, processing
44.88% of all payment transactions, followed by Paytm
(20.52%) and PhonePe (17.17%). The transaction
distribution indicates a significant reliance on Razorpay,
making its reliability and uptime critical to ensuring
smooth payment operations and minimizing transaction
disruptions.
*/

-- ============================================================
-- SECTION 2: Payment Method Performance
-- Queries 6–10
-- ============================================================

-- ============================================================
-- Query 06
-- KPI: Revenue by Payment Method
-- ============================================================
--
-- Business Question:
-- Which payment methods generate the highest revenue from
-- completed payment transactions?
--
-- Business Value:
-- Compares the revenue generated by each payment method,
-- helping identify which payment options contribute the
-- most to business revenue. This analysis supports payment
-- strategy, promotional campaigns, checkout optimization,
-- and payment provider prioritization.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    payment_method,

    COUNT(*) AS total_transactions,

    ROUND(

        SUM(amount_paid),

        2

    ) AS total_revenue,

    ROUND(

        SUM(amount_paid) * 100.0 /

        SUM(SUM(amount_paid)) OVER(),

        2

    ) AS revenue_percentage,

    ROUND(

        AVG(amount_paid),

        2

    ) AS average_transaction_value

FROM payments

WHERE payment_status = 'Completed'

GROUP BY

    payment_method

ORDER BY

    total_revenue DESC;

/*
Power BI Visualization:
Clustered Bar Chart

Business Insight:
UPI is the highest revenue-generating payment method,
contributing 34.35% of the total revenue collected from
completed payments, followed by Credit Card transactions
at 25.45%. While UPI dominates both transaction volume and
revenue, Wallet users record the highest average transaction
value (₹3,591.76), indicating a tendency toward higher-value
purchases. These insights help optimize payment strategies,
strengthen high-performing payment partnerships, and design
targeted promotional campaigns for different customer
payment preferences.
*/

-- ============================================================
-- Query 07
-- KPI: Payment Method Success Rate
-- ============================================================
--
-- Business Question:
-- Which payment methods have the highest payment success
-- rate?
--
-- Business Value:
-- Evaluates the reliability of each payment method by
-- comparing successful payments against total payment
-- attempts. This analysis helps identify the most reliable
-- payment options, improve customer checkout experience,
-- and optimize payment strategy.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    payment_method,

    COUNT(*) AS total_transactions,

    COUNT(*)
    FILTER (
        WHERE payment_status = 'Completed'
    ) AS successful_transactions,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE payment_status = 'Completed'
        ) * 100.0 /

        COUNT(*),

        2

    ) AS payment_success_rate

FROM payments

GROUP BY

    payment_method

ORDER BY

    payment_success_rate DESC,
    total_transactions DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Cash on Delivery records the highest payment success rate
at 98.14%, as payment is collected upon delivery, minimizing
online transaction failures. Among digital payment methods,
UPI achieves the highest success rate at 94.27%, followed
closely by Credit Card (94.01%) and Debit Card (93.87%).
Wallet (93.23%) and Net Banking (93.50%) show slightly
lower success rates, indicating opportunities to improve
payment processing reliability and reduce checkout failures.
*/

-- ============================================================
-- Query 08
-- KPI: Payment Processing Fee Analysis
-- ============================================================
--
-- Business Question:
-- Which payment methods incur the highest payment
-- processing fees?
--
-- Business Value:
-- Analyzes payment processing costs across different
-- payment methods, helping the business understand the
-- financial impact of transaction fees. This KPI supports
-- cost optimization, payment strategy, and negotiations
-- with payment service providers.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    payment_method,

    COUNT(*) AS total_transactions,

    ROUND(

        SUM(payment_processing_fee),

        2

    ) AS total_processing_fee,

    ROUND(

        AVG(payment_processing_fee),

        2

    ) AS average_processing_fee,

    ROUND(

        SUM(payment_processing_fee) * 100.0 /

        SUM(SUM(payment_processing_fee)) OVER(),

        2

    ) AS processing_fee_percentage

FROM payments

WHERE payment_status = 'Completed'

GROUP BY

    payment_method

ORDER BY

    total_processing_fee DESC;

/*
Power BI Visualization:
Clustered Bar Chart

Business Insight:
Credit Card payments account for the highest processing
cost, contributing 39.48% of the total processing fees,
despite representing only 25.45% of the total payment
revenue. In contrast, UPI generates the highest revenue
while maintaining a significantly lower average processing
fee per transaction (₹33.90), making it the most
cost-efficient digital payment method. Cash on Delivery
incurs no payment processing fees, while Wallet and Net
Banking maintain moderate processing costs. These insights
help optimize payment strategies, improve profit margins,
and support negotiations with payment service providers.
*/

-- ============================================================
-- Query 09
-- KPI: Customer Spending by Payment Method
-- ============================================================
--
-- Business Question:
-- Which payment methods generate the highest average
-- transaction value?
--
-- Business Value:
-- Compares the average transaction value across payment
-- methods to identify customer spending patterns. This
-- analysis helps the business understand which payment
-- methods are associated with higher-value purchases and
-- supports targeted payment promotions and marketing
-- strategies.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DENSE_RANK() OVER (

        ORDER BY AVG(amount_paid) DESC

    ) AS transaction_value_rank,

    payment_method,

    COUNT(*) AS total_transactions,

    ROUND(

        AVG(amount_paid),

        2

    ) AS average_transaction_value,

    ROUND(

        MIN(amount_paid),

        2

    ) AS minimum_transaction_value,

    ROUND(

        MAX(amount_paid),

        2

    ) AS maximum_transaction_value

FROM payments

WHERE payment_status = 'Completed'

GROUP BY

    payment_method

ORDER BY

    average_transaction_value DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Wallet users record the highest average transaction value
of ₹3,591.76, followed by Credit Card (₹3,505.55) and
Net Banking (₹3,474.65). Although UPI processes the largest
number of transactions, customers using Wallet and Credit
Card tend to make higher-value purchases. These insights
can help the business design targeted payment offers,
premium customer campaigns, and payment-specific promotions
to maximize revenue from high-value transactions.
*/

-- ============================================================
-- Query 10
-- KPI: Refund Analysis by Payment Method
-- ============================================================
--
-- Business Question:
-- Which payment methods have the highest refund volume and
-- refund amount?
--
-- Business Value:
-- Evaluates refund trends across different payment methods
-- by measuring the number of refunded transactions, refund
-- value, and refund rate. This analysis helps identify
-- payment methods associated with higher refund risk,
-- enabling better fraud monitoring, customer service
-- improvements, and payment policy optimization.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    payment_method,

    COUNT(*) AS total_transactions,

    COUNT(*)
    FILTER (
        WHERE payment_status = 'Refunded'
    ) AS refunded_transactions,

    ROUND(

        SUM(refund_amount),

        2

    ) AS total_refund_amount,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE payment_status = 'Refunded'
        ) * 100.0 /

        COUNT(*),

        2

    ) AS refund_rate

FROM payments

GROUP BY

    payment_method

ORDER BY

    total_refund_amount DESC,
    refund_rate DESC;

/*
Power BI Visualization:
Clustered Bar Chart

Business Insight:
Credit Card transactions account for the highest total
refund amount (₹232,659.05), followed by UPI
(₹206,801.63), indicating the greatest financial impact
from refunds. Although Cash on Delivery represents the
smallest transaction volume, it records the highest refund
rate (1.10%), while Credit Card and Net Banking each
maintain a refund rate of 1.04%. Monitoring both refund
value and refund rate helps identify payment methods that
require closer operational monitoring, stronger fraud
controls, and improved customer dispute management.
*/

-- ============================================================
-- SECTION 3: Payment Trends & Operational Insights
-- Queries 11–15
-- ============================================================

-- ============================================================
-- Query 11
-- KPI: Monthly Payment Revenue Trend
-- ============================================================
--
-- Business Question:
-- How has payment revenue changed over time?
--
-- Business Value:
-- Analyzes monthly revenue collected from completed payment
-- transactions to identify revenue trends, seasonal demand,
-- and business growth. This KPI helps management monitor
-- financial performance and supports strategic planning,
-- forecasting, and budgeting.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC('month', payment_timestamp)::DATE
    AS payment_month,

    COUNT(*) AS completed_transactions,

    ROUND(

        SUM(amount_paid),

        2

    ) AS total_revenue,

    ROUND(

        AVG(amount_paid),

        2

    ) AS average_transaction_value

FROM payments

WHERE payment_status = 'Completed'

GROUP BY

    DATE_TRUNC('month', payment_timestamp)

ORDER BY

    payment_month;

/*
Power BI Visualization:
Line Chart

Business Insight:
Monthly payment revenue remains consistently strong across
the analysis period, with revenue generally ranging between
₹1.60 million and ₹2.18 million per month. The highest
monthly revenue was recorded in July 2025 (₹2.18 million),
followed closely by December 2023 (₹2.16 million), while
February 2025 recorded the lowest revenue (₹1.61 million).
Overall, the platform demonstrates stable payment
performance with no prolonged periods of revenue decline,
indicating healthy transaction activity and consistent
customer purchasing behavior.
*/

-- ============================================================
-- Query 12
-- KPI: Monthly Payment Success Rate Trend
-- ============================================================
--
-- Business Question:
-- How has the payment success rate changed over time?
--
-- Business Value:
-- Monitors the monthly payment success rate to evaluate
-- the reliability of the payment system over time.
-- Tracking this KPI helps identify periods with increased
-- payment failures, assess payment gateway performance,
-- and support continuous improvements to the checkout
-- experience.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC('month', payment_timestamp)::DATE
    AS payment_month,

    COUNT(*) AS total_transactions,

    COUNT(*)
    FILTER (
        WHERE payment_status = 'Completed'
    ) AS successful_transactions,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE payment_status = 'Completed'
        ) * 100.0 /

        COUNT(*),

        2

    ) AS payment_success_rate

FROM payments

GROUP BY

    DATE_TRUNC('month', payment_timestamp)

ORDER BY

    payment_month;

/*
Power BI Visualization:
Line Chart

Business Insight:
The platform maintains a consistently high monthly payment
success rate, generally ranging between 92% and 96%
throughout the analysis period. The highest success rate
was recorded in February 2023 (95.78%), while the lowest
occurred in March 2025 (92.08%). Despite minor monthly
variations, payment reliability remains stable over time,
indicating a robust payment infrastructure and a consistent
customer checkout experience.
*/

-- ============================================================
-- Query 13
-- KPI: Monthly Refund Trend
-- ============================================================
--
-- Business Question:
-- How have refund transactions and refund amounts changed
-- over time?
--
-- Business Value:
-- Monitors monthly refund activity to identify trends in
-- customer refunds and their financial impact. This
-- analysis helps detect periods with increased refund
-- requests, evaluate product and service quality, and
-- support proactive operational improvements.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC('month', payment_timestamp)::DATE
    AS payment_month,

    COUNT(*)
    FILTER (
        WHERE payment_status = 'Refunded'
    ) AS refunded_transactions,

    ROUND(

        SUM(refund_amount),

        2

    ) AS total_refund_amount,

    ROUND(

        AVG(refund_amount)
        FILTER (
            WHERE payment_status = 'Refunded'
        ),

        2

    ) AS average_refund_amount

FROM payments

WHERE payment_status = 'Refunded'

GROUP BY

    DATE_TRUNC('month', payment_timestamp)

ORDER BY

    payment_month;

/*
Power BI Visualization:
Combo Chart
(Column: Refunded Transactions
Line: Total Refund Amount)

Business Insight:
Monthly refund activity remains relatively low throughout
the analysis period, generally ranging from 1 to 10
refunded transactions per month. The highest refund amount
was recorded in March 2026 (₹48,238.70), while the largest
refund volume occurred in April 2023, April 2025, and
January 2026, each with 10 refunded transactions. The
variation between refund volume and refund amount indicates
that months with fewer refunds can still have a significant
financial impact due to higher-value transactions.
*/

-- ============================================================
-- Query 14
-- KPI: Payment Activity by Day of Week
-- ============================================================
--
-- Business Question:
-- On which days of the week are payment transactions
-- most active?
--
-- Business Value:
-- Analyzes payment activity by day of the week to identify
-- peak transaction periods. This insight helps optimize
-- promotional campaigns, staffing, payment infrastructure,
-- and operational planning during high-demand periods.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    TRIM(

        TO_CHAR(

            payment_timestamp,

            'Day'

        )

    ) AS day_of_week,

    COUNT(*) AS total_transactions,

    ROUND(

        SUM(amount_paid),

        2

    ) AS total_revenue,

    ROUND(

        AVG(amount_paid),

        2

    ) AS average_transaction_value

FROM payments

WHERE payment_status = 'Completed'

GROUP BY

    EXTRACT(DOW FROM payment_timestamp),

    day_of_week

ORDER BY

    EXTRACT(DOW FROM payment_timestamp);

/*
Power BI Visualization:
Clustered Column Chart

Business Insight:
Payment activity remains consistently distributed throughout
the week, with Saturday generating the highest revenue
(₹11.93 million) and the highest transaction volume
(3,440 transactions), followed closely by Monday and
Thursday. Sunday records the highest average transaction
value (₹3,497.73), while Thursday achieves the highest
overall average transaction value (₹3,523.52). The balanced
distribution of payment activity indicates stable customer
purchasing behavior, enabling consistent operational
planning and reducing dependence on a single peak business
day.
*/

-- ============================================================
-- Query 15
-- KPI: Payment Performance by Order Source
-- ============================================================
--
-- Business Question:
-- How does payment performance differ between Website and
-- Mobile App orders?
--
-- Business Value:
-- Compares payment performance across sales channels by
-- analyzing transaction volume, payment success, revenue,
-- and customer spending. This analysis helps evaluate
-- channel effectiveness, optimize the checkout experience,
-- and support investment decisions for digital platforms.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    o.order_source,

    COUNT(*) AS total_transactions,

    COUNT(*)
    FILTER (
        WHERE p.payment_status = 'Completed'
    ) AS completed_transactions,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE p.payment_status = 'Completed'
        ) * 100.0 /

        COUNT(*),

        2

    ) AS payment_success_rate,

    ROUND(

        SUM(amount_paid)
        FILTER (
            WHERE p.payment_status = 'Completed'
        ),

        2

    ) AS total_revenue,

    ROUND(

        AVG(amount_paid)
        FILTER (
            WHERE p.payment_status = 'Completed'
        ),

        2

    ) AS average_transaction_value

FROM payments p

JOIN orders o
ON p.order_id = o.order_id

GROUP BY

    o.order_source

ORDER BY

    total_revenue DESC;

/*
Power BI Visualization:
Clustered Bar Chart

Business Insight:
The Website remains the primary sales channel, processing
14,891 payment transactions and generating ₹48.33 million
in completed payment revenue, compared to ₹32.69 million
from the Mobile App. Both channels maintain an excellent
payment success rate above 94%, indicating a consistent
checkout experience regardless of platform. The similar
average transaction values (₹3,445.81 for Website and
₹3,437.45 for Mobile App) suggest that customer spending
behavior remains consistent across both digital channels,
reflecting a well-optimized omnichannel payment ecosystem.
*/

