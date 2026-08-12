-- ============================================================
-- E-Commerce Analytics Project
-- Return Analysis
-- ============================================================
--
-- Objective:
-- Analyze product returns, refund trends, customer return
-- behavior, and return reasons to identify opportunities
-- for improving product quality, customer satisfaction,
-- and operational efficiency.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Return KPIs
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Returns
-- ============================================================
--
-- Business Question:
-- How many products have been returned?
--
-- Business Value:
-- Measures the overall number of returned products within
-- the business. This KPI provides a high-level overview of
-- return activity and helps monitor return trends over time.
--
-- Business Users:
-- Operations Manager
-- Customer Experience Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS total_returns

FROM returns;

/*
Power BI Visualization:
KPI Card

Business Insight:

Represents the total number of returned products recorded
in the system. Monitoring this KPI helps evaluate overall
return volume and identify changes in customer return
behavior over time.
*/

-- ============================================================
-- Query 02
-- KPI: Overall Return Rate
-- ============================================================
--
-- Business Question:
-- What percentage of sold products are returned?
--
-- Business Value:
-- Return rate is one of the most important e-commerce KPIs.
-- A high return rate may indicate quality issues, inaccurate
-- product descriptions, or customer dissatisfaction.
--
-- Business Users:
-- Business Analyst
-- Operations Manager
-- Product Manager
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    ROUND(

        COUNT(r.return_id) * 100.0 /

        COUNT(oi.order_item_id),

        2

    ) AS return_rate_percent

FROM order_items oi

LEFT JOIN returns r
ON oi.order_item_id = r.order_item_id;

/*
Power BI Visualization:
KPI Card

Business Insight:

Measures the percentage of sold products that customers
returned. A consistently increasing return rate should be
investigated to identify potential issues with products,
shipping quality, or customer expectations.
*/

-- ============================================================
-- Query 03
-- KPI: Returns by Return Status
-- ============================================================
--
-- Business Question:
-- What is the distribution of return requests by status?
--
-- Business Value:
-- Helps monitor the operational progress of return requests
-- and identify processing delays.
--
-- Business Users:
-- Customer Support Manager
-- Operations Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    return_status,

    COUNT(*) AS total_returns

FROM returns

GROUP BY

    return_status

ORDER BY

    total_returns DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:

Shows the proportion of returns across different processing
statuses. Monitoring this distribution helps identify
backlogs, improve return processing efficiency, and enhance
customer experience.
*/

-- ============================================================
-- Query 04 
-- KPI: Returns by Refund Status
-- ============================================================
--
-- Business Question:
-- How many returns fall under each refund status?
--
-- Business Value:
-- Tracks refund completion and helps ensure customers receive
-- timely refunds while identifying refund processing delays.
--
-- Business Users:
-- Finance Team
-- Customer Support Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    refund_status,

    COUNT(*) AS total_returns

FROM returns

GROUP BY

    refund_status

ORDER BY

    total_returns DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:

Provides visibility into refund processing progress.
Delayed refunds can negatively impact customer satisfaction
and increase customer support workload.
*/

-- ============================================================
-- Query 05 
-- KPI: Returns by Return Type
-- ============================================================
--
-- Business Question:
-- Which return types occur most frequently?
--
-- Business Value:
-- Identifies the most common types of product returns,
-- helping operations teams optimize reverse logistics and
-- improve return handling processes.
--
-- Business Users:
-- Operations Manager
-- Warehouse Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    return_type,

    COUNT(*) AS total_returns

FROM returns

GROUP BY

    return_type

ORDER BY

    total_returns DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Highlights the most common return types processed by the
business. Understanding return type distribution supports
better logistics planning and more efficient return
management.
*/

-- ============================================================
-- SECTION 2: Return Cause & Product Analysis
-- Queries 6–10
-- ============================================================
-- 
-- Objective:
-- Analyze the major causes behind product returns and identify
-- categories, products, and sellers contributing to return
-- problems. This analysis helps improve product quality,
-- customer satisfaction, and operational efficiency.
--
-- ============================================================

-- ============================================================
-- Query 06 
-- KPI: Top Return Reasons
-- ============================================================
--
-- Business Question:
-- Which return reasons account for the highest number of
-- product returns?
--
-- Business Value:
-- Identifies the primary causes behind product returns,
-- enabling the business to improve product quality,
-- product descriptions, packaging, and delivery processes.
--
-- Business Users:
-- Product Manager
-- Quality Assurance Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Intermediate (Window Functions)
-- ============================================================


SELECT

    DENSE_RANK() OVER (

        ORDER BY COUNT(*) DESC

    ) AS return_reason_rank,


    return_reason,


    COUNT(*) AS total_returns,


    ROUND(

        COUNT(*) * 100.0 /

        SUM(COUNT(*)) OVER (),

        2

    ) AS return_percentage


FROM returns


GROUP BY

    return_reason


ORDER BY

    total_returns DESC;


/*
Power BI Visualization:
Horizontal Bar Chart


Business Insight:

Highlights the most common reasons customers return
products. Understanding these reasons helps identify
quality issues, misleading product information, shipping
damage, or customer expectation gaps.


Business Recommendation:

The business should prioritize the highest return causes
by improving product descriptions, strengthening quality
checks, optimizing packaging standards, and addressing
recurring customer complaints.
*/

-- ============================================================
-- Query 07 
-- KPI: Categories with Highest Return Rate
-- ============================================================
--
-- Business Question:
-- Which product categories have the highest return rate
-- compared to their sales volume?
--
-- Business Value:
-- Identifies categories experiencing higher return problems.
-- This helps category managers investigate product quality,
-- supplier performance, inaccurate product information, and
-- customer expectation gaps.
--
-- Business Users:
-- Category Manager
-- Product Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Advanced (CTE + Multiple Joins + Window Functions)
-- ============================================================


WITH category_return_analysis AS (

    SELECT

        c.category_id,

        c.category_name,


        COUNT(oi.order_item_id) AS total_items_sold,


        COUNT(r.return_id) AS total_returns


    FROM categories c


    JOIN products p
    ON c.category_id = p.category_id


    JOIN order_items oi
    ON p.product_id = oi.product_id


    LEFT JOIN returns r
    ON oi.order_item_id = r.order_item_id


    GROUP BY

        c.category_id,

        c.category_name

)


SELECT


    DENSE_RANK() OVER (

        ORDER BY

            ROUND(

                total_returns * 100.0 /

                total_items_sold,

                2

            ) DESC

    ) AS category_rank,


    category_name,


    total_items_sold,


    total_returns,


    ROUND(

        total_returns * 100.0 /

        total_items_sold,

        2

    ) AS return_rate_percent


FROM category_return_analysis


ORDER BY

    return_rate_percent DESC;


/*
Power BI Visualization:
Horizontal Bar Chart


Business Insight:

Compares return performance across product categories by
measuring the percentage of sold items that are returned.

Categories with higher return rates may indicate product
quality problems, inaccurate product information, supplier
issues, or customer expectation gaps.


Business Recommendation:

High-return categories should be analyzed further at the
product and seller level to identify recurring issues.
Improving supplier quality checks, product descriptions,
and customer guidance can help reduce return rates and
improve customer satisfaction.
*/


-- ============================================================
-- Query 08
-- KPI: Products with Highest Return Rate
-- ============================================================
--
-- Business Question:
-- Which products have the highest return rate compared to
-- their sales volume?
--
-- Business Value:
-- Identifies products with unusually high return rates,
-- helping product managers investigate quality issues,
-- misleading product information, supplier performance,
-- and customer expectation gaps.
--
-- Business Users:
-- Product Manager
-- Category Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Advanced (CTE + Multiple Joins + Window Functions)
-- ============================================================

WITH product_return_analysis AS (

    SELECT

        p.product_id,

        p.product_name,

        p.brand,

        COUNT(oi.order_item_id) AS total_items_sold,

        COUNT(r.return_id) AS total_returns

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    LEFT JOIN returns r
        ON oi.order_item_id = r.order_item_id

    WHERE p.is_active = TRUE

    GROUP BY

        p.product_id,

        p.product_name,

        p.brand

)

SELECT

    DENSE_RANK() OVER (

        ORDER BY

            ROUND(

                total_returns * 100.0 /
                total_items_sold,

                2

            ) DESC,

            total_returns DESC

    ) AS product_rank,

    product_id,

    product_name,

    brand,

    total_items_sold,

    total_returns,

    ROUND(

        total_returns * 100.0 /
        total_items_sold,

        2

    ) AS return_rate_percent

FROM product_return_analysis

WHERE total_items_sold >= 20

ORDER BY

    return_rate_percent DESC,

    total_returns DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Highlights the products with the highest return rates after
considering their sales volume. Using a minimum sales
threshold ensures the analysis focuses on products with
sufficient transaction history, making the results more
reliable for business decision-making.

Products with consistently high return rates may indicate
quality issues, inaccurate product descriptions, supplier
defects, or unmet customer expectations.

Business Recommendation:

Product managers should prioritize reviewing the highest
return-rate products by analyzing customer feedback,
return reasons, and supplier performance. Improving product
quality, descriptions, images, and quality assurance
processes can help reduce return rates, lower reverse
logistics costs, and improve customer satisfaction.
*/

-- ============================================================
-- Query 09 
-- KPI: Monthly Return Trend
-- ============================================================
--
-- Business Question:
-- How has the number of product returns changed over time?
--
-- Business Value:
-- Tracks monthly return trends to identify seasonal
-- patterns, operational issues, or sudden increases in
-- return activity. This helps the business evaluate the
-- effectiveness of quality improvements and return
-- reduction initiatives over time.
--
-- Business Users:
-- Operations Manager
-- Product Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Intermediate (Date Functions)
-- ============================================================

SELECT

    TO_CHAR(

        DATE_TRUNC('month', return_date),

        'Mon YYYY'

    ) AS return_month,

    COUNT(*) AS total_returns

FROM returns

GROUP BY

    DATE_TRUNC('month', return_date)

ORDER BY

    DATE_TRUNC('month', return_date);


/*
Power BI Visualization:
Line Chart

Business Insight:

Shows how product returns change over time by month.
Monitoring return trends helps identify seasonal return
patterns, operational issues, and periods with unusually
high return activity. Comparing monthly return volumes
also enables the business to evaluate the impact of
quality improvement initiatives.

Business Recommendation:

Months with unusually high return volumes should be
investigated by analyzing return reasons, affected
products, and supplier performance. Tracking return
trends over time supports proactive inventory planning,
quality improvements, and customer satisfaction
initiatives.
*/

-- ============================================================
-- Query 10 
-- KPI: Sellers with Highest Return Rate
-- ============================================================
--
-- Business Question:
-- Which sellers have the highest return rate compared to
-- the number of products they have sold?
--
-- Business Value:
-- Identifies sellers with unusually high return rates,
-- helping evaluate seller performance, identify product
-- quality issues, and improve marketplace standards.
--
-- Business Users:
-- Marketplace Manager
-- Seller Performance Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Advanced (CTE + Multiple Joins + Window Functions)
-- ============================================================

WITH seller_sales AS (

    SELECT

        p.seller_id,

        COUNT(oi.order_item_id) AS total_items_sold

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY

        p.seller_id

),

seller_returns AS (

    SELECT

        seller_id,

        COUNT(*) AS total_returns

    FROM returns

    GROUP BY

        seller_id

)

SELECT

    DENSE_RANK() OVER (

        ORDER BY

            ROUND(

                COALESCE(sr.total_returns, 0) * 100.0 /

                ss.total_items_sold,

                2

            ) DESC,

            COALESCE(sr.total_returns, 0) DESC

    ) AS seller_rank,

    s.seller_id,

    s.seller_name,

    ss.total_items_sold,

    COALESCE(sr.total_returns, 0) AS total_returns,

    ROUND(

        COALESCE(sr.total_returns, 0) * 100.0 /

        ss.total_items_sold,

        2

    ) AS return_rate_percent

FROM seller_sales ss

JOIN sellers s
    ON ss.seller_id = s.seller_id

LEFT JOIN seller_returns sr
    ON ss.seller_id = sr.seller_id

WHERE ss.total_items_sold >= 20

ORDER BY

    return_rate_percent DESC,

    total_returns DESC

LIMIT 10;


/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Ranks sellers based on their product return rate relative
to the number of items sold. Evaluating return rates rather
than total return counts provides a fair comparison of
seller performance, regardless of sales volume.

Sellers with consistently high return rates may indicate
product quality issues, inaccurate product listings,
packaging defects, or fulfillment challenges.

Business Recommendation:

Marketplace managers should regularly monitor seller return
rates and investigate sellers with consistently poor
performance. Targeted quality audits, seller training, and
listing improvements can help reduce return rates, improve
customer satisfaction, and maintain marketplace quality.
*/

-- ============================================================
-- SECTION 3: Return Financial Impact
-- Queries 11–13
-- ============================================================
--
-- Objective:
-- Analyze the financial impact of product returns by
-- measuring refund amounts and identifying the products
-- and categories contributing the most to refund losses.
-- This analysis helps the business reduce revenue leakage,
-- improve profitability, and prioritize corrective actions.
--
-- ============================================================

-- ============================================================
-- Query 11 
-- KPI: Total Refund Amount
-- ============================================================
--
-- Business Question:
-- What is the total refund amount issued for returned
-- products?
--
-- Business Value:
-- Measures the total financial impact of product returns on
-- the business. This KPI helps finance and operations teams
-- monitor refund expenses, evaluate return-related losses,
-- and assess the effectiveness of return reduction
-- initiatives.
--
-- Business Users:
-- Finance Manager
-- Operations Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        SUM(refund_amount),

        2

    ) AS total_refund_amount

FROM returns;


/*
Power BI Visualization:
KPI Card


Business Insight:

Represents the total amount refunded to customers for
returned products. Monitoring this KPI provides visibility
into the direct financial impact of returns and helps the
business evaluate how return activity affects revenue and
profitability.


Business Recommendation:

The business should regularly monitor refund expenses
alongside return rates. Combining financial impact with
return reason, product, and seller analysis enables
management to prioritize improvement efforts that deliver
the greatest reduction in refund costs.
*/

-- ============================================================
-- Query 12 
-- KPI: Products with Highest Refund Loss
-- ============================================================
--
-- Business Question:
-- Which products have resulted in the highest total refund
-- amount?
--
-- Business Value:
-- Identifies products responsible for the greatest financial
-- loss due to customer returns. This helps prioritize
-- product quality improvements, supplier evaluations, and
-- pricing strategies to minimize refund costs.
--
-- Business Users:
-- Finance Manager
-- Product Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Advanced (Joins + Aggregation + Window Functions)
-- ============================================================

SELECT

    DENSE_RANK() OVER (

        ORDER BY

            SUM(r.refund_amount) DESC,

            COUNT(r.return_id) DESC

    ) AS refund_loss_rank,

    p.product_id,

    p.product_name,

    p.brand,

    COUNT(r.return_id) AS total_returns,

    ROUND(

        SUM(r.refund_amount),

        2

    ) AS total_refund_amount,

    ROUND(

        AVG(r.refund_amount),

        2

    ) AS average_refund_amount

FROM returns r

JOIN products p
    ON r.product_id = p.product_id

GROUP BY

    p.product_id,
    p.product_name,
    p.brand

ORDER BY

    total_refund_amount DESC,

    total_returns DESC

LIMIT 10;


/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Ranks products based on the total refund amount issued due
to customer returns, providing a clear view of the products
that have the greatest financial impact on the business.

Unlike return count alone, refund amount highlights the
true financial cost of returns. High-value products may
generate substantial refund losses even with relatively
few return transactions.

Monitoring these products enables the business to identify
quality issues, supplier performance concerns, pricing
risks, or customer expectation gaps that directly affect
profitability.

Business Recommendation:

Product managers should regularly review products with the
highest refund losses and investigate the underlying causes
using return reasons, customer reviews, and supplier
performance data. Prioritizing corrective actions for these
high-value products can significantly reduce refund costs,
improve profitability, and enhance customer satisfaction.
*/

-- ============================================================
-- Query 13 
-- KPI: Categories with Highest Refund Loss
-- ============================================================
--
-- Business Question:
-- Which product categories generate the highest refund
-- losses due to customer returns?
--
-- Business Value:
-- Identifies product categories responsible for the largest
-- financial losses from refunds. This enables management to
-- prioritize quality improvements, supplier negotiations,
-- and category-specific strategies to reduce refund costs
-- and improve profitability.
--
-- Business Users:
-- Finance Manager
-- Category Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Advanced (Multiple Joins + Aggregation + Window Functions)
-- ============================================================

SELECT

    DENSE_RANK() OVER (

        ORDER BY

            SUM(r.refund_amount) DESC,

            COUNT(r.return_id) DESC

    ) AS refund_loss_rank,

    c.category_id,

    c.category_name,

    COUNT(r.return_id) AS total_returns,

    ROUND(

        SUM(r.refund_amount),

        2

    ) AS total_refund_amount,

    ROUND(

        AVG(r.refund_amount),

        2

    ) AS average_refund_amount

FROM returns r

JOIN products p
    ON r.product_id = p.product_id

JOIN categories c
    ON p.category_id = c.category_id

GROUP BY

    c.category_id,
    c.category_name

ORDER BY

    total_refund_amount DESC,

    total_returns DESC;


/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:

Ranks product categories based on the total refund amount
issued due to customer returns. This analysis identifies
which categories contribute the most to refund-related
financial losses and highlights areas requiring strategic
attention.

Comparing total refund amount alongside total returns helps
distinguish between categories with frequent low-value
returns and those with fewer but significantly more
expensive returns.

Business Recommendation:

Management should prioritize quality improvement
initiatives, supplier evaluations, and product listing
reviews for categories with the highest refund losses.
Reducing refunds within these categories can significantly
improve profitability while enhancing the overall customer
experience.
*/

-- ============================================================
-- SECTION 4: Return Operations Analysis
-- Queries 14–15
-- ============================================================
--
-- Objective:
-- Analyze operational efficiency within the product return
-- process by evaluating customer return behavior and the
-- outcomes of returned product quality inspections.
--
-- This analysis helps improve reverse logistics, optimize
-- warehouse operations, reduce operational costs, and
-- support better inventory recovery decisions.
--
-- ============================================================

-- ============================================================
-- Query 14 
-- KPI: Average Days Before Return
-- ============================================================
--
-- Business Question:
-- On average, how many days after delivery do customers
-- initiate product returns?
--
-- Business Value:
-- Measures customer return behavior by identifying the
-- average time taken to return products after delivery.
-- Understanding return timing helps evaluate product
-- quality, customer satisfaction, and the effectiveness
-- of return policies.
--
-- Business Users:
-- Operations Manager
-- Customer Experience Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        AVG(days_after_delivery),

        2

    ) AS average_days_before_return

FROM returns;


/*
Power BI Visualization:
KPI Card

Business Insight:

Represents the average number of days customers take to
initiate a return after product delivery.

A shorter average return period may indicate immediate
issues such as damaged products, incorrect deliveries,
or manufacturing defects, while longer return periods may
suggest issues discovered only after product usage.

Business Recommendation:

The business should monitor changes in the average return
period over time. Combining this KPI with return reasons
and product categories can help identify recurring quality
issues and improve post-purchase customer satisfaction.
*/

-- ============================================================
-- Query 15 
-- KPI: Return Quality Inspection Status Analysis
-- ============================================================
--
-- Business Question:
-- What is the distribution of returned products based on
-- their quality inspection status?
--
-- Business Value:
-- Analyzes the outcome of quality inspections performed on
-- returned products. This helps determine how many returned
-- items can be restocked, require refurbishment, or must
-- be written off, supporting efficient reverse logistics
-- and inventory recovery.
--
-- Business Users:
-- Warehouse Manager
-- Operations Manager
-- Business Analyst
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    quality_check_status,

    COUNT(*) AS total_returns,

    ROUND(

        COUNT(*) * 100.0 /

        SUM(COUNT(*)) OVER (),

        2

    ) AS return_percentage

FROM returns

GROUP BY

    quality_check_status

ORDER BY

    total_returns DESC;


/*
Power BI Visualization:
Donut Chart

Business Insight:

Shows the distribution of returned products across
different quality inspection outcomes. This analysis
helps evaluate the effectiveness of the return inspection
process and provides visibility into the condition of
returned inventory.

A high proportion of failed quality inspections may
indicate recurring product quality issues, inadequate
packaging, or shipping damage, while a high percentage
of passed inspections suggests opportunities to restock
and recover inventory value.

Business Recommendation:

Warehouse and operations teams should continuously monitor
quality inspection outcomes to identify recurring quality
issues and improve inventory recovery. Products that
frequently fail inspection should be investigated for
supplier defects, packaging improvements, or logistics
issues to reduce financial losses and enhance customer
satisfaction.
*/