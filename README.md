# Brazilian-ecommerce-analysis
From 329 orders in 2016 to 54,000+ in 2018 — a deep-dive SQL analysis on Brazil's largest e-commerce platform uncovering customer behavior, delivery failures, revenue trends and business growth patterns using PostgreSQL.
This project performs an end-to-end SQL analysis on the Olist Brazilian E-Commerce dataset — one of the most comprehensive public e-commerce datasets available, containing 100,000+ real orders placed between 2016 and 2018.
The goal was to think like a Data Analyst — not just query data, but extract meaningful business insights that can drive decisions around logistics, customer retention, product quality, and revenue growth.

🗂️ Dataset
Source: Kaggle — Brazilian E-Commerce Public Dataset by Olist




🛠️ Tools Used

PostgreSQL — all analysis and schema design
pgAdmin — query execution and ERD design
GitHub — version control and portfolio

🔍 Analysis Covered

1. 👥 Customer Analysis

Unique customers by state and city
Repeat vs one-time buyer segmentation (CASE WHEN)
Customers active across all 3 years (INTERSECT)
Delivered customers who never reviewed (EXCEPT)
New customer acquisition by month (CTE + MIN)
Top customers per state by spend (ROW_NUMBER + PARTITION BY)


2. 🏪 Seller Analysis

Top 5 sellers by revenue
Average order value per seller
Seller vs city performance (ROW_NUMBER + PARTITION BY)
Top customer per seller (RANK + PARTITION BY)
Sellers with most delayed deliveries

3. 💰 Revenue & Payments

Monthly revenue trend with MoM growth (LAG + CTE)
Top 5 revenue-generating product categories
Revenue by payment type
Credit card dominates — both in count and revenue

4. ⭐ Review Analysis

Rating distribution — 5-star most frequent
Higher ratings = Higher revenue (confirmed)

5. 🔁 Funnel Analysis

% orders delivered vs % orders reviewed
Drop-off identification using FILTER clause


6. 🎯 Customer Segmentation

Top 10% customers by spend (NTILE)
Bottom 10% customers by spend
High-value vs low-value customer identification


🔍 Key Insights
Business scaled rapidly from 329 orders (2016) to 54,011 (2018)
Customer acquisition peaked around mid-2017

Some deliveries occurred much earlier than estimated, indicating conservative timelines
Extreme delays (up to 188 days) highlight operational issues
São Paulo (SP) and certain cities show high delayed deliveries
Indicates region-specific logistics inefficiencies

Customer retention is extremely low
Majority are one-time buyers
646 customers did not leave reviews after delivery
Indicates drop in post-purchase engagement

Higher ratings are associated with higher revenue
Product quality directly impacts business performance
Credit card is the dominant payment method

💡 Business Recommendations:

Improve logistics in high-delay regions
Focus on customer retention (loyalty programs, re-engagement)
Enhance product quality in low-rated categories
Encourage customer reviews through incentives
Target high-value customers with personalized strategies

🧠 SQL Concepts Used
JOINs · CTEs · Window Functions · RANK · ROW_NUMBER · NTILE · LAG · PARTITION BY · CASE WHEN · FILTER · INTERSECT · EXCEPT · EXTRACT · Subqueries · HAVING · unaccent extension

📌 Conclusion

This project demonstrates the use of SQL for end-to-end business analysis, including data exploration, segmentation, and insight generation.
The findings highlight key areas for improvement in customer retention, delivery operations, and product quality.

👤 Author
Chitransh Jain
