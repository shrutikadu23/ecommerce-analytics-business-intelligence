-- ============================================================
-- E-Commerce Analytics Project
-- Wishlist Analysis
-- ============================================================
--
-- Objective:
-- Analyze customer wishlist behavior to measure product
-- demand, customer purchase intent, and engagement using
-- business-focused SQL queries.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Wishlist KPIs
-- Queries 1–4
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Wishlist Items
-- ============================================================
--
-- Business Question:
-- How many products have been added to customer wishlists?
--
-- Business Value:
-- Measures the overall level of customer purchase intent by
-- tracking the total number of wishlist entries. A higher
-- wishlist volume indicates stronger customer interest in
-- products and helps estimate future purchasing demand.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS total_wishlist_items

FROM wishlist;

/*
Power BI Visualization:
KPI Card

Business Insight:
A total of 31,458 products have been added to customer
wishlists, indicating strong customer purchase intent and
active engagement with the platform's wishlist feature.
This volume of wishlist activity provides valuable insight
into future product demand and helps identify products with
high sales potential for targeted marketing and inventory
planning.
*/

-- ============================================================
-- Query 02
-- KPI: Customers Using Wishlist
-- ============================================================
--
-- Business Question:
-- How many unique customers actively use the wishlist
-- feature?
--
-- Business Value:
-- Measures customer adoption of the wishlist feature by
-- identifying the number of unique customers who have
-- added products to their wishlists. This KPI helps assess
-- customer engagement and the popularity of the wishlist
-- feature across the platform.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(DISTINCT customer_id) AS customers_using_wishlist

FROM wishlist;

/*
Power BI Visualization:
KPI Card

Business Insight:
A total of 7,914 unique customers actively use the wishlist
feature, demonstrating strong customer engagement and
adoption across the platform. This indicates that a
significant portion of the customer base uses wishlists to
save products for future consideration, providing valuable
insights into purchase intent and potential future demand.
*/

-- ============================================================
-- Query 03
-- KPI: Average Wishlist Size per Customer
-- ============================================================
--
-- Business Question:
-- On average, how many products does each customer save
-- in their wishlist?
--
-- Business Value:
-- Measures the average number of products saved by each
-- customer, providing insight into customer engagement and
-- purchase consideration behavior. Larger wishlists may
-- indicate stronger product exploration and higher future
-- purchase potential.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        COUNT(*) * 1.0

        /

        COUNT(DISTINCT customer_id),

        2

    ) AS average_wishlist_size

FROM wishlist;

/*
Power BI Visualization:
KPI Card

Business Insight:
Customers save an average of 3.97 products in their
wishlists, indicating consistent engagement with the
wishlist feature and active product exploration before
making purchase decisions. This behavior reflects strong
purchase intent and provides opportunities for personalized
recommendations, promotional campaigns, and targeted
remarketing initiatives.
*/

-- ============================================================
-- Query 04
-- KPI: Wishlist Coverage
-- ============================================================
--
-- Business Question:
-- What percentage of registered customers use the wishlist
-- feature?
--
-- Business Value:
-- Measures customer adoption of the wishlist feature by
-- calculating the percentage of registered customers who
-- have created at least one wishlist entry. This KPI helps
-- evaluate feature adoption, customer engagement, and the
-- effectiveness of encouraging customers to save products
-- for future purchases.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    COUNT(DISTINCT w.customer_id) AS customers_using_wishlist,

    COUNT(c.customer_id) AS total_customers,

    ROUND(

        COUNT(DISTINCT w.customer_id) * 100.0

        /

        COUNT(c.customer_id),

        2

    ) AS wishlist_coverage_percentage

FROM customers c

LEFT JOIN wishlist w
ON c.customer_id = w.customer_id;

/*
Power BI Visualization:
KPI Card

Business Insight:
Out of 33,544 registered customers, 7,914 have used the
wishlist feature, resulting in a wishlist adoption rate of
23.59%. This indicates that nearly one in four customers
actively save products for future purchases, highlighting
the wishlist as an important customer engagement feature
and a valuable source of purchase intent for personalized
marketing and remarketing strategies.
*/

-- ============================================================
-- SECTION 2: Product Demand Analysis
-- Queries 5–8
-- ============================================================

-- ============================================================
-- Query 05
-- KPI: Top 10 Most Wishlisted Products
-- ============================================================
--
-- Business Question:
-- Which products are most frequently added to customer
-- wishlists?
--
-- Business Value:
-- Identifies products generating the highest customer
-- purchase interest before an actual purchase occurs.
-- These products are strong candidates for targeted
-- promotions, inventory planning, personalized
-- recommendations, and demand forecasting.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    w.product_id,

    p.product_name,

    c.category_name,

    COUNT(w.wishlist_id) AS wishlist_count,

    ROUND(

        MAX(p.price),

      2

    ) AS product_price,

    ROUND(

        MAX(p.average_rating),

        2

    ) AS average_product_rating

FROM wishlist w

JOIN products p
ON w.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

GROUP BY

    w.product_id,
    p.product_name,
    c.category_name

ORDER BY

    wishlist_count DESC,
    average_product_rating DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
The most wishlisted products received between 59 and 120
wishlist additions, reflecting strong customer purchase
interest across multiple product categories. Books dominate
the rankings, accounting for four of the top six most
wishlisted products, while Electronics and Health also
feature prominently. These products represent high-demand
items that should be prioritized for inventory planning,
personalized recommendations, promotional campaigns, and
conversion-focused marketing initiatives.
*/

-- ============================================================
-- Query 06
-- KPI: Most Wishlisted Categories
-- ============================================================
--
-- Business Question:
-- Which product categories generate the highest customer
-- purchase interest based on wishlist activity?
--
-- Business Value:
-- Identifies product categories with the greatest customer
-- demand before purchases occur. Understanding category-level
-- wishlist activity helps support inventory planning,
-- merchandising strategies, promotional campaigns, and
-- product assortment decisions.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    c.category_name,

    COUNT(w.wishlist_id) AS wishlist_count,

    ROUND(

        COUNT(w.wishlist_id) * 100.0

        /

        SUM(COUNT(w.wishlist_id)) OVER(),

        2

    ) AS wishlist_percentage,

    ROUND(

        MAX(p.average_rating),

        2

    ) AS average_product_rating

FROM wishlist w

JOIN products p
ON w.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

GROUP BY

    c.category_name

ORDER BY

    wishlist_count DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Wishlist activity is distributed across all product
categories, with Grocery (11.44%), Beauty & Personal Care
(11.12%), and Toys & Games (11.10%) generating the highest
customer purchase interest. Although the differences between
categories are relatively small, these leading categories
represent the strongest opportunities for targeted marketing,
inventory optimization, and promotional campaigns to convert
customer interest into future sales.
*/

-- ============================================================
-- Query 07
-- KPI: Seller-wise Wishlist Popularity
-- ============================================================
--
-- Business Question:
-- Which sellers generate the highest customer purchase
-- interest based on wishlist activity?
--
-- Business Value:
-- Evaluates seller performance by measuring the number of
-- wishlist additions received across their products.
-- Sellers with highly wishlisted products demonstrate
-- stronger customer demand and may benefit from increased
-- inventory allocation, promotional campaigns, and strategic
-- marketplace visibility.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    s.seller_id,

    s.seller_name,

    COUNT(w.wishlist_id) AS wishlist_count,

    COUNT(DISTINCT w.customer_id) AS interested_customers,

    ROUND(

        AVG(p.average_rating),

        2

    ) AS average_product_rating

FROM wishlist w

JOIN products p
ON w.product_id = p.product_id

JOIN sellers s
ON p.seller_id = s.seller_id

GROUP BY

    s.seller_id,
    s.seller_name

HAVING

    COUNT(w.wishlist_id) >= 30

ORDER BY

    wishlist_count DESC,

    average_product_rating DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
The highest-performing sellers attracted between 171 and
449 wishlist additions from 171 to 429 unique customers,
demonstrating strong customer purchase interest across
their product portfolios. BrightHub generated the highest
wishlist activity, while sellers such as GalaxyElectronics,
RoyalElectronics, and GalaxyOutlet maintained excellent
average product ratings above 4.65. These sellers represent
high-demand marketplace partners and should be prioritized
for featured placements, promotional campaigns, and
inventory planning to maximize conversion opportunities.
*/

-- ============================================================
-- Query 08
-- KPI: High-Rated Products Frequently Wishlisted
-- ============================================================
--
-- Business Question:
-- Which highly rated products also receive significant
-- customer wishlist activity?
--
-- Business Value:
-- Identifies products that combine strong customer demand
-- with high customer satisfaction. These products are ideal
-- candidates for featured listings, recommendation engines,
-- promotional campaigns, and inventory prioritization,
-- as they have both proven quality and strong purchase
-- intent.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    w.product_id,

    p.product_name,

    c.category_name,

    COUNT(w.wishlist_id) AS wishlist_count,

    MAX(p.average_rating) AS average_product_rating,

    ROUND(

        MAX(p.price),

        2

    ) AS product_price

FROM wishlist w

JOIN products p
ON w.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

GROUP BY

    w.product_id,
    p.product_name,
    c.category_name

HAVING

    COUNT(w.wishlist_id) >= 20

    AND MAX(p.average_rating) >= 4.5

ORDER BY

    wishlist_count DESC,

    average_product_rating DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
The highest-performing products combine strong customer
purchase interest with excellent customer satisfaction,
receiving between 50 and 90 wishlist additions while
maintaining average ratings of 4.5 or higher. Books,
Electronics, and Health dominate the rankings, indicating
that these products have both proven quality and high
purchase intent. They should be prioritized for featured
placements, recommendation engines, promotional campaigns,
and inventory planning to maximize sales conversions.
*/

-- ============================================================
-- SECTION 3: Customer Wishlist Behavior & Business Opportunities
-- Queries 9–12
-- ============================================================

-- ============================================================
-- Query 09
-- KPI: Monthly Wishlist Trend
-- ============================================================
--
-- Business Question:
-- How has customer wishlist activity changed over time?
--
-- Business Value:
-- Tracks monthly wishlist additions to measure changes in
-- customer purchase intent and engagement. Identifying
-- seasonal trends helps forecast demand, optimize inventory,
-- and plan promotional campaigns during periods of increased
-- customer interest.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    DATE_TRUNC('month', added_date)::DATE AS month,

    COUNT(wishlist_id) AS wishlist_additions,

    COUNT(DISTINCT customer_id) AS unique_customers,

    COUNT(DISTINCT product_id) AS unique_products

FROM wishlist

GROUP BY

    month

ORDER BY

    month;

/*
Power BI Visualization:
Line Chart

Business Insight:
Wishlist activity remained consistently strong throughout
the analysis period, averaging approximately 850 wishlist
additions per month after the initial partial month of
July 2023. Monthly engagement involved around 750–850
unique customers and nearly 700 unique products,
indicating stable customer purchase intent and sustained
interest across a diverse range of products. This
consistent trend supports reliable demand forecasting and
inventory planning throughout the year.
*/

-- ============================================================
-- Query 10
-- KPI: Most Active Wishlist Customers
-- ============================================================
--
-- Business Question:
-- Which customers have added the highest number of products
-- to their wishlists?
--
-- Business Value:
-- Identifies highly engaged customers based on their
-- wishlist activity. These customers demonstrate strong
-- product exploration and purchase intent, making them
-- ideal candidates for personalized recommendations,
-- loyalty programs, exclusive offers, and targeted
-- remarketing campaigns.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    w.customer_id,

    c.first_name || ' ' || c.last_name AS customer_name,

    COUNT(w.wishlist_id) AS wishlist_items,

    COUNT(DISTINCT w.product_id) AS unique_products,

    ROUND(

       AVG(p.price)

        2

    ) AS average_product_price

FROM wishlist w

JOIN customers c
ON w.customer_id = c.customer_id

JOIN products p
ON w.product_id = p.product_id

GROUP BY

    w.customer_id,
    customer_name

HAVING

    COUNT(w.wishlist_id) >= 10

ORDER BY

    wishlist_items DESC,

    average_product_price DESC,

    customer_id ASC

LIMIT 10;

/*
Power BI Visualization:
Table

Business Insight:
The most engaged customers each saved 20 unique products
to their wishlists, demonstrating exceptionally high
levels of product exploration and purchase intent. These
customers represent valuable targets for personalized
recommendations, exclusive promotions, loyalty programs,
and remarketing campaigns, as their strong engagement
suggests a higher likelihood of future purchases.
*/

-- ============================================================
-- Query 11
-- KPI: Wishlist Conversion Analysis
-- ============================================================
--
-- Business Question:
-- What percentage of wishlist items have been moved to the
-- shopping cart?
--
-- Business Value:
-- Measures how effectively wishlist activity converts into
-- purchase consideration. A higher conversion rate indicates
-- stronger customer purchase intent, while a lower rate may
-- highlight opportunities for personalized reminders,
-- promotional campaigns, and remarketing strategies.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    COUNT(*) FILTER (
        WHERE moved_to_cart = TRUE
    ) AS moved_to_cart,

    COUNT(*) AS total_wishlist_items,

    ROUND(

        COUNT(*) FILTER (
            WHERE moved_to_cart = TRUE
        ) * 100.0

        /

        COUNT(*),

        2

    ) AS wishlist_conversion_rate

FROM wishlist;

/*
Power BI Visualization:
KPI Card

Business Insight:
Out of 31,458 wishlist items, 10,897 were moved to the
shopping cart, resulting in a wishlist conversion rate of
34.64%. This indicates that approximately one in three
wishlist additions progresses to the purchase consideration
stage, demonstrating strong customer buying intent while
also highlighting opportunities for personalized reminders,
price-drop notifications, and targeted remarketing campaigns
to improve conversion rates.
*/

-- ============================================================
-- Query 12
-- KPI: Highly Wishlisted Products with Low Sales
-- ============================================================
--
-- Business Question:
-- Which products generate high customer interest through
-- wishlist activity but record relatively low sales?
--
-- Business Value:
-- Identifies products with strong customer demand that are
-- not converting into purchases. These products may be
-- affected by pricing, competition, product information,
-- or promotional effectiveness. The analysis supports
-- pricing optimization, targeted discounts, inventory
-- planning, and conversion-focused marketing strategies.
--
-- SQL Difficulty:
-- Advanced
-- ============================================================

SELECT

    p.product_id,

    p.product_name,

    c.category_name,

    COUNT(DISTINCT w.wishlist_id) AS wishlist_count,

    COUNT(DISTINCT oi.order_item_id) AS units_sold,

    ROUND(

        COUNT(DISTINCT oi.order_item_id) * 100.0

        /

        NULLIF(COUNT(DISTINCT w.wishlist_id), 0),

        2

    ) AS sales_to_wishlist_ratio,

    ROUND(

        MAX(p.average_rating),

        2

    ) AS average_product_rating

FROM products p

JOIN categories c
ON p.category_id = c.category_id

LEFT JOIN wishlist w
ON p.product_id = w.product_id

LEFT JOIN order_items oi
ON p.product_id = oi.product_id

GROUP BY

    p.product_id,
    p.product_name,
    c.category_name

HAVING

    COUNT(DISTINCT w.wishlist_id) >= 20

ORDER BY

    sales_to_wishlist_ratio ASC,

    wishlist_count DESC

LIMIT 10;

/*
Power BI Visualization:
Scatter Plot

X → Wishlist Count

Y → Units Sold

Bubble Size → Average Rating

Business Insight:
Several products generated strong customer interest but
recorded relatively low sales conversion rates despite
receiving between 48 and 120 wishlist additions. For
example, HarperCollins Eco Dictionary and Penguin Elite
Dictionary converted only about 15% of wishlist demand
into purchases. These products represent potential lost
revenue opportunities and should be evaluated for pricing,
promotional offers, product content, stock availability,
or other conversion barriers to improve sales performance.
*/

