-- ============================================================
-- E-Commerce Analytics Project
-- Review Analysis
-- ============================================================
--
-- Objective:
-- Analyze customer reviews to measure customer satisfaction,
-- product quality perception, seller performance, and review
-- behavior using business-focused SQL queries.
--
-- Database:
-- PostgreSQL 18
--
-- ============================================================

-- ============================================================
-- SECTION 1: Review KPIs
-- Queries 1–5
-- ============================================================

-- ============================================================
-- Query 01
-- KPI: Total Reviews
-- ============================================================
--
-- Business Question:
-- How many customer reviews have been submitted across all
-- completed purchases?
--
-- Business Value:
-- Measures the total volume of customer feedback received,
-- helping evaluate customer engagement and the reliability
-- of review-based product insights.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) AS total_reviews

FROM reviews;

/*
Power BI Visualization:
KPI Card

Business Insight:
A total of 33,740 customer reviews have been submitted,
indicating strong post-purchase customer engagement and a
substantial feedback base for evaluating product quality,
seller performance, and overall customer satisfaction.
This volume of reviews enhances the reliability of
rating-based analyses and supports more informed
business decisions.
*/

-- ============================================================
-- Query 02
-- KPI: Average Product Rating
-- ============================================================
--
-- Business Question:
-- What is the average customer rating across all product
-- reviews?
--
-- Business Value:
-- Measures overall customer satisfaction with products sold
-- on the platform. This KPI serves as a benchmark for
-- evaluating product quality, customer experience, and
-- future improvements.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        AVG(rating),

        2

    ) AS average_product_rating

FROM reviews;

/*
Power BI Visualization:
KPI Card

Business Insight:
The platform achieved an average customer rating of
4.25 out of 5, indicating a high level of overall
customer satisfaction. This KPI serves as a benchmark
for evaluating product quality, seller performance, and
customer experience across the platform while providing
a reference point for future rating trend analysis.
*/

-- ============================================================
-- Query 03
-- KPI: Positive Review Rate (%)
-- ============================================================
--
-- Business Question:
-- What percentage of customer reviews are positive?
--
-- Business Value:
-- Measures the proportion of positive customer feedback,
-- providing an overall indication of customer satisfaction
-- and product acceptance. This KPI helps monitor brand
-- perception and identify opportunities to improve the
-- customer experience.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*) FILTER (
        WHERE rating >= 4
    ) AS positive_reviews,

    COUNT(*) AS total_reviews,

    ROUND(

        COUNT(*) FILTER (
            WHERE rating >= 4
        ) * 100.0

        /

        COUNT(*),

        2

    ) AS positive_review_rate

FROM reviews;

/*
Power BI Visualization:
KPI Card

Business Insight:
Out of 33,740 customer reviews, 26,961 were positive,
resulting in a positive review rate of 79.91%. This
indicates that nearly four out of every five customers
reported a satisfactory product experience, reflecting
strong customer satisfaction and positive product
acceptance across the platform.
*/

-- ============================================================
-- Query 04
-- KPI: Verified Purchase Review Rate
-- ============================================================
--
-- Business Question:
-- What percentage of customer reviews were submitted by
-- verified purchasers?
--
-- Business Value:
-- Measures the credibility and authenticity of customer
-- feedback by identifying reviews submitted after verified
-- purchases. A higher verified review rate increases the
-- reliability of product ratings and supports greater
-- customer trust in review-based purchasing decisions.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    COUNT(*)
    FILTER (
        WHERE purchase_verified = TRUE
    ) AS verified_reviews,

    COUNT(*) AS total_reviews,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE purchase_verified = TRUE
        ) * 100.0

        /

        COUNT(*),

        2

    ) AS verified_purchase_review_rate

FROM reviews;

/*
Power BI Visualization:
KPI Card

Business Insight:
All 33,740 customer reviews were submitted by verified
purchasers, resulting in a verified purchase review rate
of 100%. This indicates that the platform restricts
reviews to customers who have completed a purchase,
ensuring high review authenticity and increasing the
credibility of product ratings and customer feedback.
*/

-- ============================================================
-- Query 05
-- KPI: Average Review Helpfulness Score
-- ============================================================
--
-- Business Question:
-- What is the average helpfulness score of customer reviews?
--
-- Business Value:
-- Measures how useful customer reviews are to other shoppers.
-- Higher helpfulness scores indicate that reviews provide
-- valuable product information, improving customer trust
-- and supporting better purchase decisions.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    ROUND(

        AVG(helpfulness_score),

        2

    ) AS average_helpfulness_score

FROM reviews;

/*
Power BI Visualization:
KPI Card

Business Insight:
Customer reviews achieved an average helpfulness score of
0.33, indicating that many reviews are considered useful
by shoppers when evaluating products. This metric helps
measure the overall quality and usefulness of customer
feedback, supporting better purchasing decisions and
highlighting the value of informative product reviews.
*/

-- ============================================================
-- Query 06
-- KPI: Top 10 Highest Rated Products
-- ============================================================
--
-- Business Question:
-- Which products consistently receive the highest customer
-- ratings based on a sufficient number of approved reviews?
--
-- Business Value:
-- Identifies top-performing products with consistently high
-- customer satisfaction. Applying a minimum review threshold
-- ensures rankings are based on reliable customer feedback
-- rather than a small number of reviews. These products are
-- strong candidates for featured listings, promotional
-- campaigns, and recommendation engines.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    r.product_id,

    p.product_name,

    c.category_name,

    COUNT(r.review_id) AS total_reviews,

    ROUND(

        AVG(r.rating),

        2

    ) AS average_rating,

    ROUND(

        AVG(r.helpfulness_score),

        2

    ) AS average_helpfulness_score

FROM reviews r

JOIN products p
ON r.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

WHERE

    r.review_status = 'Approved'

GROUP BY

    r.product_id,
    p.product_name,
    c.category_name

HAVING

    COUNT(r.review_id) >= 20

ORDER BY

    average_rating DESC,
    total_reviews DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
The top-performing products achieved average customer
ratings between 4.52 and 4.75 based on at least 20
approved reviews, indicating consistently high customer
satisfaction backed by reliable feedback. These products
are strong candidates for featured placements, promotional
campaigns, and recommendation engines to maximize customer
engagement and sales.
*/

-- ============================================================
-- Query 07
-- KPI: Lowest Rated Products
-- ============================================================
--
-- Business Question:
-- Which products consistently receive the lowest customer
-- ratings based on a sufficient number of approved reviews?
--
-- Business Value:
-- Identifies underperforming products that may require
-- quality improvements, supplier evaluation, or enhanced
-- customer support. Applying a minimum review threshold
-- ensures decisions are based on reliable customer feedback
-- rather than isolated negative reviews.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    r.product_id,

    p.product_name,

    c.category_name,

    COUNT(r.review_id) AS total_reviews,

    ROUND(

        AVG(r.rating),

        2

    ) AS average_rating,

    ROUND(

        AVG(r.helpfulness_score),

        2

    ) AS average_helpfulness_score

FROM reviews r

JOIN products p
ON r.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

WHERE

    r.review_status = 'Approved'

GROUP BY

    r.product_id,
    p.product_name,
    c.category_name

HAVING

    COUNT(r.review_id) >= 20

ORDER BY

    average_rating ASC,
    total_reviews DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
The lowest-performing products recorded average customer
ratings between 3.80 and 3.91 based on at least 20 approved
reviews, indicating consistently lower customer satisfaction.
These products should be prioritized for quality assessment,
supplier evaluation, and customer feedback analysis to identify
the root causes of dissatisfaction and improve future product
performance.
*/

-- ============================================================
-- Query 08
-- KPI: Seller Satisfaction Analysis
-- ============================================================
--
-- Business Question:
-- Which sellers deliver the highest levels of customer
-- satisfaction based on review quality and customer feedback?
--
-- Business Value:
-- Evaluates seller performance using multiple customer
-- satisfaction metrics rather than relying on average
-- ratings alone. This analysis helps identify high-performing
-- sellers for marketplace recognition while highlighting
-- sellers that may require quality improvements or additional
-- support.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    r.seller_id,

    s.seller_name,

    COUNT(r.review_id) AS total_reviews,

    ROUND(

        AVG(r.rating),

        2

    ) AS average_rating,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE r.rating >= 4
        ) * 100.0

        /

        COUNT(*),

        2

    ) AS positive_review_rate,

    ROUND(

        AVG(r.helpfulness_score),

        2

    ) AS average_helpfulness_score

FROM reviews r

JOIN sellers s
ON r.seller_id = s.seller_id

WHERE

    r.review_status = 'Approved'

GROUP BY

    r.seller_id,
    s.seller_name

HAVING

    COUNT(r.review_id) >= 30

ORDER BY

     average_rating DESC,

    positive_review_rate DESC,

    average_helpfulness_score DESC,

    total_reviews DESC

LIMIT 10;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
The highest-performing sellers achieved average customer
ratings between 4.51 and 4.60 while maintaining positive
review rates above 89% based on at least 30 approved
reviews. These sellers consistently deliver positive
customer experiences and can serve as performance
benchmarks for improving overall marketplace quality.
*/

-- ============================================================
-- Query 09
-- KPI: Category-wise Average Rating
-- ============================================================
--
-- Business Question:
-- Which product categories receive the highest average
-- customer ratings?
--
-- Business Value:
-- Evaluates customer satisfaction across product categories,
-- helping identify high-performing categories while
-- highlighting areas that may require improvements in
-- product quality, supplier selection, or customer
-- experience.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    c.category_name,

    COUNT(r.review_id) AS total_reviews,

    ROUND(

        AVG(r.rating),

        2

    ) AS average_rating,

    ROUND(

        COUNT(*)
        FILTER (
            WHERE r.rating >= 4
        ) * 100.0

        /

        COUNT(*),

        2

    ) AS positive_review_rate,

    ROUND(

        AVG(r.helpfulness_score),

        2

    ) AS average_helpfulness_score

FROM reviews r

JOIN products p
ON r.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

WHERE

    r.review_status = 'Approved'

GROUP BY

    c.category_name

ORDER BY

    average_rating DESC,

    positive_review_rate DESC,

    average_helpfulness_score DESC;

/*
Power BI Visualization:
Horizontal Bar Chart

Business Insight:
Customer satisfaction remained consistently high across all
product categories, with average ratings ranging from 4.20
to 4.26 and positive review rates between 78.24% and 81.00%.
Automotive achieved the highest customer satisfaction,
whereas Electronics recorded the lowest average rating,
highlighting potential opportunities for product quality
improvements and enhanced customer experience within that
category.
*/

-- ============================================================
-- Query 10
-- KPI: Rating Distribution (1★–5★)
-- ============================================================
--
-- Business Question:
-- How are customer ratings distributed across all approved
-- product reviews?
--
-- Business Value:
-- Analyzes the distribution of customer ratings to
-- understand overall customer sentiment and identify the
-- proportion of highly satisfied, neutral, and dissatisfied
-- customers. This helps monitor product quality and overall
-- customer experience.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    rating,

    COUNT(review_id) AS total_reviews,

    ROUND(

        COUNT(review_id) * 100.0
        /

        SUM(COUNT(review_id)) OVER(),

        2

    ) AS review_percentage

FROM reviews

WHERE

    review_status = 'Approved'

GROUP BY

    rating

ORDER BY

    rating DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:
The review distribution is heavily skewed toward positive
feedback, with 79.88% of all approved reviews receiving
4-star or 5-star ratings. More than half of all customer
reviews (54.90%) awarded the highest possible rating,
while only 8.03% were rated 1 or 2 stars. This distribution
indicates consistently high customer satisfaction and
strong overall product performance across the platform.
*/

-- ============================================================
-- SECTION 3: Customer Feedback Intelligence
-- Queries 11–16
-- ============================================================

-- ============================================================
-- Query 11
-- KPI: Monthly Review Trend
-- ============================================================
--
-- Business Question:
-- How has customer review activity changed month by month?
--
-- Business Value:
-- Tracks customer engagement by monitoring the volume of
-- approved reviews over time. This analysis helps identify
-- seasonal patterns, customer participation trends, and
-- periods of increased or decreased review activity,
-- supporting customer engagement and product feedback
-- strategies.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    DATE_TRUNC('month', review_date)::DATE AS month,

    COUNT(review_id) AS total_reviews,

    COUNT(DISTINCT customer_id) AS unique_reviewers,

    ROUND(

        AVG(rating),

        2

    ) AS average_rating

FROM reviews

WHERE

    review_status = 'Approved'

GROUP BY

    month

ORDER BY

    month;

/*
Power BI Visualization:
Line Chart

Business Insight:
Customer review activity remained consistently strong
throughout the analysis period, averaging approximately
700–800 approved reviews per month. Customer satisfaction
also remained stable, with average monthly ratings ranging
between 4.18 and 4.31, indicating consistently positive
customer experiences and sustained engagement with the
platform's review system.
*/

-- ============================================================
-- Query 12
-- KPI: Monthly Average Rating Trend
-- ============================================================
--
-- Business Question:
-- How has the average customer rating changed month by month?
--
-- Business Value:
-- Monitors customer satisfaction trends over time by
-- tracking the monthly average product rating. This
-- analysis helps identify periods of improving or
-- declining customer satisfaction and supports proactive
-- quality improvement initiatives.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    DATE_TRUNC('month', review_date)::DATE AS month,

    ROUND(

        AVG(rating),

        2

    ) AS average_rating,

    COUNT(review_id) AS total_reviews,

    ROUND(

        COUNT(*) FILTER (
            WHERE rating >= 4
        ) * 100.0

        /

        COUNT(*),

        2

    ) AS positive_review_rate

FROM reviews

WHERE

    review_status = 'Approved'

GROUP BY

    month

ORDER BY

    month;

/*
Power BI Visualization:
Line Chart

Business Insight:
Customer satisfaction remained consistently high throughout
the analysis period, with monthly average ratings ranging
between 4.18 and 4.31 and positive review rates fluctuating
between 77.02% and 82.78%. The stable trend indicates
consistent product quality and customer experience, with
only minor month-to-month variations that do not suggest
any significant decline in overall customer satisfaction.
*/

-- ============================================================
-- Query 13
-- KPI: Sentiment Distribution
-- ============================================================
--
-- Business Question:
-- What is the distribution of customer review sentiments
-- across all approved reviews?
--
-- Business Value:
-- Analyzes the overall sentiment expressed in customer
-- reviews to understand how customers perceive products
-- and services. Monitoring sentiment distribution helps
-- identify customer satisfaction levels and detect
-- potential areas requiring improvement.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    sentiment,

    COUNT(review_id) AS total_reviews,

    ROUND(

        COUNT(review_id) * 100.0

        /

        SUM(COUNT(review_id)) OVER(),

        2

    ) AS review_percentage

FROM reviews

WHERE

    review_status = 'Approved'

GROUP BY

    sentiment

ORDER BY

    total_reviews DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:
Customer sentiment is overwhelmingly positive, with 79.88%
of approved reviews expressing positive feedback, while
12.09% are neutral and only 8.03% are negative. This
distribution indicates strong overall customer satisfaction,
although the negative sentiment segment should be monitored
to identify recurring product or service issues and drive
continuous improvement.
*/

-- ============================================================
-- Query 14
-- KPI: Reviews with Images vs Without Images
-- ============================================================
--
-- Business Question:
-- How many customer reviews include product images, and
-- how do they compare with text-only reviews?
--
-- Business Value:
-- Measures customer engagement by analyzing the adoption
-- of image-based reviews. Reviews containing images often
-- provide richer product information, increase buyer
-- confidence, and improve the overall shopping experience.
-- Understanding their distribution helps evaluate customer
-- participation and the effectiveness of encouraging visual
-- feedback.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    CASE

        WHEN has_review_images = TRUE
            THEN 'With Images'

        ELSE 'Without Images'

    END AS review_type,

    COUNT(review_id) AS total_reviews,

    ROUND(

        COUNT(review_id) * 100.0

        /

        SUM(COUNT(review_id)) OVER(),

        2

    ) AS review_percentage,

    ROUND(

        AVG(rating),

        2

    ) AS average_rating

FROM reviews

WHERE

    review_status = 'Approved'

GROUP BY

    review_type

ORDER BY

    total_reviews DESC;

/*
Power BI Visualization:
Clustered Column Chart

Business Insight:
Approximately 25% of approved customer reviews include
product images, while 75% are text-only reviews. The
average rating remains nearly identical across both groups
(4.24–4.25), indicating that image-based reviews primarily
enhance product transparency and customer confidence rather
than influencing overall satisfaction levels.
*/

-- ============================================================
-- Query 15
-- KPI: Seller Response Performance
-- ============================================================
--
-- Business Question:
-- How actively do sellers respond to approved customer
-- reviews?
--
-- Business Value:
-- Measures seller engagement by evaluating response rates
-- to customer reviews. Active seller responses demonstrate
-- commitment to customer service, strengthen customer trust,
-- and improve overall marketplace experience by addressing
-- customer feedback promptly.
--
-- SQL Difficulty:
-- Basic
-- ============================================================

SELECT

    seller_response_status,

    COUNT(review_id) AS total_reviews,

    ROUND(

        COUNT(review_id) * 100.0

        /

        SUM(COUNT(review_id)) OVER(),

        2

    ) AS review_percentage,

    ROUND(

        AVG(rating),

        2

    ) AS average_rating

FROM reviews

WHERE

    review_status = 'Approved'

GROUP BY

    seller_response_status

ORDER BY

    total_reviews DESC;

/*
Power BI Visualization:
Donut Chart

Business Insight:
Only 5.64% of approved reviews received seller responses,
while 94.36% remained unanswered. Reviews that received
seller responses had a significantly lower average rating
(1.74) compared to the overall platform average, indicating
that sellers primarily engage with dissatisfied customers
to address complaints and resolve service or product issues.
*/

-- ============================================================
-- Query 16
-- KPI: Most Helpful Reviews Analysis
-- ============================================================
--
-- Business Question:
-- Which customer reviews provide the most valuable feedback
-- based on community helpful votes?
--
-- Business Value:
-- Identifies the most influential customer reviews that
-- assist other shoppers in making informed purchase
-- decisions. These reviews provide valuable insights into
-- product quality, customer expectations, and common
-- purchasing experiences while highlighting feedback that
-- has the greatest impact on buying decisions.
--
-- SQL Difficulty:
-- Intermediate
-- ============================================================

SELECT

    r.review_id,

    p.product_name,

    c.category_name,

    r.rating,

    r.review_title,

    r.helpful_votes,

    ROUND(

        r.helpfulness_score,

        2

    ) AS helpfulness_score,

    r.sentiment,

    r.purchase_verified,

    r.has_review_images

FROM reviews r

JOIN products p
ON r.product_id = p.product_id

JOIN categories c
ON p.category_id = c.category_id

WHERE

    r.review_status = 'Approved'

    AND r.helpful_votes >= 50

ORDER BY

    r.helpfulness_score DESC,

    r.helpful_votes DESC

LIMIT 10;

/*
Power BI Visualization:
Table

Business Insight:
The most helpful customer reviews were overwhelmingly
submitted by verified purchasers and received up to 100
helpful votes with helpfulness scores approaching 1.00.
These highly influential reviews span multiple product
categories and provide valuable guidance for prospective
buyers while offering actionable product feedback for the
business to improve product quality and customer experience.
*/

