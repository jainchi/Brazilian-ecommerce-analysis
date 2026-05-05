CREATE TABLE sellers_dataset(
seller_id VARCHAR(50) PRIMARY KEY,
seller_zip_code BIGINT,
seller_city VARCHAR(55),
seller_state VARCHAR(15));

CREATE TABLE products_dataset(
product_id	VARCHAR(55) PRIMARY KEY,
product_category_name	VARCHAR(55),
product_name_lenght	BIGINT,
product_description_lenght 	BIGINT,
product_photos_qty	BIGINT,
product_weight_g	BIGINT,
product_length_cm	BIGINT,
product_height_cm	BIGINT,
product_width_cm BIGINT
);

CREATE TABLE order_items_dataset(
order_id VARCHAR(50) ,
order_item_id BIGINT ,
product_id	VARCHAR(55) REFERENCES products_dataset(product_id),
seller_id  VARCHAR(55) REFERENCES sellers_dataset(seller_id),
shipping_limit_date	TIMESTAMP,
price float,
freight_value float,
PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE customers_dataset(
customer_id VARCHAR(60) PRIMARY KEY,
customer_unique_id VARCHAR(65),
customer_zip_code_prefix BIGINT,
customer_city VARCHAR(50),
customer_state VARCHAR(25));


CREATE TABLE order_payments_dataset(
order_id varchar(60) NOT NULL ,
payment_sequential	BIGINT,
payment_type	VARCHAR(60),
payment_installments	BIGINT,
payment_value	DECIMAL(10,2)
);

CREATE TABLE olist_orders (
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(20),
    order_placed_time TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_reviews (
    review_id VARCHAR(50) ,
    order_id VARCHAR(50) ,
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


CREATE TABLE product_category_name_english(
product_category_name VARCHAR(150)	,
product_category_name_english VARCHAR(150)
);

CREATE TABLE geolocation_dataset(

geolocation_zip_code_prefix	BIGINT,
geolocation_lat	 FLOAT,
geolocation_lng	FLOAT,
geolocation_city	VARCHAR(55),
geolocation_state VARCHAR(20)
);

SELECT * FROM olist_orders
SELECT * FROM products_dataset
SELECT * FROM sellers_dataset
SELECT * FROM customers_dataset
SELECT * FROM order_items_dataset
SELECT * FROM order_payments_dataset
SELECT * FROM order_reviews
SELECT * FROM product_category_name_english
SELECT * FROM geolocation_dataset



-- Checking in which column there are missing values 
SELECT count(*) FROM olist_orders
SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_status) AS order_status_not_null,
    COUNT(order_placed_time) AS order_placed_time_not_null,
    COUNT(order_approved_at) AS order_approved_at_not_null,
	COUNT(order_delivered_carrier_date) AS order_delivered_carrier_date_not_null,
	COUNT(order_delivered_customer_date) AS order_delivered_customer_date_not_null,
	COUNT(order_estimated_delivery_date) AS order_estimated_delivery_date_not_null
FROM olist_orders;


/*-- output:-
Missing values were present in some columns, but are very less approx 3k out of 99441 rows.
Since the proportion is relatively low, it is unlikely to have a significant impact on the analysis.
We should not delete these null values, because I believe that this is not any kind of mistake it is just in a half-way process and will be
enterd in record soon.
*/


-- Checking distinct values in order_status column
SELECT DISTINCT order_status from olist_orders

-- Outcome. Total 8 type of status are there in order_status column



-- Q.How much order have placed in total by year

SELECT EXTRACT(YEAR FROM order_placed_time)as year,count(*)as totalorders
from olist_orders
group by  EXTRACT(YEAR FROM order_placed_time)
-- Outcome. In Year 2016 total '329' orders are place, In year 2017 total '45101' are placed and in 2018 maximum '54011 'orders have been placed.


-- Q. Find the Differnce in day&time between a customer has placed ordered and received the order(max and min both)

SELECT max(order_delivered_customer_date - order_placed_time) AS maxtimedifference,
min(order_delivered_customer_date - order_placed_time) AS mintimedifference
from olist_orders 
WHERE order_delivered_customer_date IS NOT NULL;
-- Outcome.> Maximum duration between a customer has placed an order and receives it is (209 days+15hrs) and minimum is(12hr 48 minutes approx)


-- Q. Find the Differnce in day&time between the estimated product delivery and has actually been received.

SELECT max(order_estimated_delivery_date- order_delivered_customer_date) as days_beforeestimated,
min(order_estimated_delivery_date- order_delivered_customer_date) AS daysbefore_or_afterestimated FROM olist_orders
WHERE order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
-- Outcome. The 1st result is a very big win for us, we have delivered product 146 day before the estimated date, but
-- The second result is quite disappointing, it's coming (-188 days), which means we had taken 188 days extra after the estimated delivery date.




-- Q. Anlayse how many product are there in each category.
SELECT product_category_name, COUNT(product_category_name) AS totalcount
FROM products_dataset
GROUP BY product_category_name
ORDER BY 2 DESC


-- Q.How many distinct seller's city are there in data?
SELECT DISTINCT seller_city from sellers_dataset
order by seller_city

-- Outcome. There are 611 different seller_city in the dataset


-- Q.Find sellers count by city and tell in which city seller is maximum and where is minimum

SELECT seller_city, COUNT(*) as citysellercount
FROM sellers_dataset
WHERE seller_city IS NOT NULL
GROUP BY 1
order by 2 desc

CREATE EXTENSION IF NOT EXISTS unaccent;
SELECT 
    unaccent(TRIM(LOWER(seller_city))) AS cleaned_city,
    COUNT(*) AS citysellercount
FROM sellers_dataset
WHERE seller_city IS NOT NULL
GROUP BY TRIM(LOWER(seller_city))
ORDER BY citysellercount DESC;


SELECT seller_city, COUNT(*) AS cnt
FROM sellers_dataset
WHERE LOWER(seller_city) LIKE '%sao paulo%'
GROUP BY seller_city
ORDER BY cnt DESC;



-- Check the count of unique customer from each state
SELECT customer_state, COUNT(DISTINCT customer_unique_id) AS noofcustomers 
FROM customers_dataset
GROUP BY 1
ORDER BY 1

-- We have customers from total of 23 states, with the maximum number of customers from 'SP' 



-- Q. Find the city with the maximum number of customers and check from how many distinct cities customers are from.
SELECT customer_city, COUNT(DISTINCT customer_unique_id) AS noofcustomers 
FROM customers_dataset
GROUP BY 1
ORDER BY 2 DESC

-- Sao paulo has the maximum no. of customers and we have customers from total 4.1k different cities.


-- ----------------------------------
-- FIND COUNT BY order_item_id?
SELECT order_item_id, COUNT(*) AS totalcount
FROM order_items_dataset
GROUP BY 1
ORDER BY 2 DESC
-- Maximum products sold are of order_item_id '1' with count of 98.6k
-- ------------------------------------------------------------------------------


SELECT * FROM  sellers_dataset
-- Count orders by seller_id and give the maximum one.
SELECT s.seller_id , COUNT(*) as totalorders
FROM order_items_dataset o
JOIN sellers_dataset s
ON o.seller_id=s.seller_id
GROUP BY 1
ORDER BY 2 DESC
-- Maximum order count by a seller among all is 2033


-- Q. Check which order_item_id has generated maximum revenue
SELECT o1.order_item_id,ROUND(SUM(price)::NUMERIC,2) AS totalamount
FROM order_items_dataset o1
JOIN olist_orders o2
ON o1.order_id=o2.order_id
GROUP BY 1
ORDER BY totalamount DESC
-- Outcome. order_item_id "1" has generated maximum revenue

--------------------------


SELECT payment_type, count(*) as countbypaymenttype
FROM order_payments_dataset
GROUP BY 1
ORDER BY 2
-- OUTCOME. Founded count of payment by each payment_type(Maximum is of credit_card )

SELECT payment_type,SUM(payment_value) AS totalpayment
FROM order_payments_dataset
GROUP BY 1
ORDER BY 2 DESC
-- Outcome. Maximum payment is made by 'credit_card' followed by 'boleto'



SELECT review_score, COUNT(review_id) as totalreviewcount
FROM order_reviews
GROUP BY 1
ORDER BY 2 DESC
-- Outcome. Maximum number of count comes are of 5star ratings.

SELECT review_score, COUNT(review_comment_message) as totalcommentcount
FROM order_reviews
WHERE review_comment_message is NOT NULL
GROUP BY 1
ORDER BY 2 DESC
-- Outcome. Maximum number of comments fell in the 5star ratings


-- Basics done here,now moving next




-- Q. Check total count by sellers
SELECT s.seller_id , COUNT(DISTINCT o1.order_id)as orderscount FROM olist_orders o1
LEFT JOIN order_items_dataset o2
ON o1.order_id=o2.order_id
JOIN sellers_dataset s
ON o2.seller_id=s.seller_id
GROUP BY 1
order BY 2 DESC
-- Outcome.“This query correctly includes all sellers and counts how many distinct orders each seller fulfilled, including those with zero orders.”


-- Q. Calculate count of orders by order_item_id of each seller
select distinct seller_id from order_items_dataset

SELECT seller_id, order_item_id, COUNT(*) AS countbyitemid
FROM order_items_dataset
GROUP BY seller_id, order_item_id
ORDER BY countbyitemid DESC;




SELECT  o2.seller_id,order_item_id,COUNT(o1.order_id) as countbyitemid
FROM olist_orders o1
LEFT JOIN order_items_dataset o2
ON o1.order_id=o2.order_id
JOIN sellers_dataset s
ON o2.seller_id=s.seller_id
GROUP BY o2.seller_id,order_item_id
order BY 3 DESC



-- Ques  1. Top 5 sellers by revenue
-- Ques  2. Average order value per seller
-- Ques  3. Seller vs city performance


SELECT * FROM order_items_dataset
SELECT * FROM olist_orders

SELECT seller_id, SUM(price)AS totalrevenue 
FROM order_items_dataset o3
GROUP BY 1
ORDER BY totalrevenue DESC
LIMIT 5 
-- I have'nt multiplied price with quantity because there is no quantity column.

SELECT * FROM order_payments_dataset
WHERE order_id='b81ef226f3fe1789b1e8b2acac839d17'

SELECT * FROM order_items_dataset
WHERE order_id='b81ef226f3fe1789b1e8b2acac839d17'
-- Checked what actually payment_value contains in order_payments_dataset(price+freight)



WITH totals  AS(
SELECT seller_id,customer_unique_id,sum(price) as totalpurchase
FROM olist_orders o
JOIN customers_dataset c
ON o.customer_id = c.customer_id
JOIN order_items_dataset o3
ON o.order_id=o3.order_id
GROUP BY 1,2
),
rankbytotalpurchase AS
(
SELECT *,RANK() OVER(PARTITION BY seller_id ORDER BY totalpurchase DESC) as rankbyrowno
from totals
)
SELECT * FROM rankbytotalpurchase
WHERE rankbyrowno <2
-- OUTCOME Have founded top customer for each seller



WITH total as(
SELECT customer_state,customer_unique_id,sum(price) as totalpurchase FROM olist_orders o
JOIN customers_dataset c
ON o.customer_id = c.customer_id
JOIN order_items_dataset o3
ON o.order_id=o3.order_id
GROUP BY 1,2
),
rankingbytotal AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_state ORDER BY totalpurchase DESC) as rankbyrowno
from total
)
SELECT * FROM rankingbytotal
WHERE rankbyrowno<3
/*
“I used the price column from the order_items table to calculate revenue,
as it represents the product value only. Using the order_payments table would include additional charges like freight,
which were intentionally excluded from this analysis.”
*/


-- Ques  2. Average order value per seller

SELECT seller_id,
    ROUND(SUM(price)::NUMERIC, 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(price) / COUNT(DISTINCT order_id))::NUMERIC, 2) AS avg_order_value
FROM order_items_dataset
GROUP BY 1
ORDER BY 4 DESC


-- Ques 3. Seller vs city performance
SELECT * FROM(
SELECT s.seller_id,customer_city, SUM(price) as totalrevenue,
ROW_NUMBER() OVER(PARTITION BY s.seller_id ORDER BY SUM(price) DESC) AS rank
FROM sellers_dataset s
JOIN order_items_dataset ov
ON s.seller_id=ov.seller_id
JOIN olist_orders oo
ON ov.order_id =oo.order_id
JOIN customers_dataset cd
ON oo.customer_id=cd.customer_id
GROUP BY 1,2
) AS ranked_data
WHERE rank<4

-- 


-- 1. Monthly Revenue Trend
-- 2. Late Delivery Rate  
-- 3. Top 5 Revenue Categories
-- 4. Repeat vs One-time Customers


WITH monthcategor as(
SELECT EXTRACT(YEAR FROM order_placed_time) AS year, 
EXTRACT(MONTH FROM order_placed_time) AS month,
ROUND(SUM(price)::NUMERIC,2) AS currentmonthrev,
LAG(ROUND(sum(price)::NUMERIC,2)) OVER(ORDER BY EXTRACT(YEAR FROM order_placed_time),EXTRACT(MONTH FROM order_placed_time)) AS prevmonthrev
FROM olist_orders oo
JOIN order_items_dataset od
ON oo.order_id=od.order_id
GROUP BY 1,2
order by 1,2
),
monthlytrend as
(
SELECT *,currentmonthrev-prevmonthrev as difference,ROUND((100*(currentmonthrev-prevmonthrev)/prevmonthrev),2) AS percentagegrowth
FROM monthcategor
)
SELECT * FROM monthlytrend
-- Above query shows monthly trend ignoring 'partition by year'



SELECT (100*COUNT(order_delivered_customer_date - order_estimated_delivery_date)::numeric/(SELECT count(*) from  olist_orders)::numeric)AS percent 
FROM olist_orders
WHERE order_delivered_customer_date > order_estimated_delivery_date
-- Aprrox 8% of the ordered orders had delivered after the estimated delivery date



SELECT product_category_name, SUM(price) as totalrev FROM order_items_dataset oot
JOIN products_dataset as pt
ON oot.product_id=pt.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
-- Above Query is showing top 5 categories by revenue.


SELECT customer_type, count(*) from(
SELECT ct.customer_unique_id,count(os.order_id),
CASE WHEN COUNT(os.order_id) > 1 THEN 'Repeat Customer'ELSE 'One-time Customer' END AS customer_type
FROM customers_dataset ct
join olist_orders os
ON ct.customer_id=os.customer_id
GROUP BY 1
) AS customer_summary
GROUP by 1
-- In our business repeat customers are very less currently in comparison of One-time customers



SELECT DISTINCT product_category_name,MAX(price) OVER (PARTITION BY product_category_name) as costliestprice
from products_dataset pt
JOIN order_items_dataset oid
ON pt.product_id =oid.product_id
GROUP BY 1,price
ORDER BY 2 DESC
-- maximum price among products of a particular category


SELECT cdt.customer_unique_id,SUM(price) as totalpurchase, COUNT(DISTINCT ols.order_id) AS purchasecount, MAX(order_placed_time) 
FROM customers_dataset cdt
JOIN olist_orders ols
ON cdt.customer_id=ols.customer_id
JOIN order_items_dataset oid
ON ols.order_id=oid.order_id
GROUP BY 1 
ORDER BY 2 DESC

-- Founded total purchase, count of transactions, last purchase date

SELECT customer_state,COUNT(DISTINCT oor.order_id)
FROM olist_orders oor
join customers_dataset cs
ON oor.customer_id=cs.customer_id
WHERE order_delivered_customer_date > order_estimated_delivery_date
GROUP BY 1
order by 2 DESC
--State “SP” has the highest number of delayed orders.



SELECT seller_id,COUNT(DISTINCT oor.order_id) as delayeddeliveries
FROM olist_orders oor
join order_items_dataset oid
ON oor.order_id=oid.order_id
WHERE order_delivered_customer_date > order_estimated_delivery_date AND
order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY 1
order by 2 DESC
-- 4a3ca9315b744ce9f8e9374361493884 has maximum delayed deliveries


WITH first_purchase AS (
    SELECT 
        ct.customer_unique_id,
        MIN(order_placed_time) AS first_order_date
    FROM olist_orders oss
	JOIN customers_dataset ct
	ON oss.customer_id=ct.customer_id
    GROUP BY ct.customer_unique_id
)
SELECT 
    EXTRACT(YEAR FROM first_order_date) AS year,
    EXTRACT(MONTH FROM first_order_date) AS month,
    COUNT(*) AS new_customers
FROM first_purchase
GROUP BY year, month
ORDER BY year, month;
-- Group customers by:First purchase month



/*
8. ⭐ Review vs Revenue (VERY INTERESTING)
Do higher ratings → more sales?
Which sellers/categories have bad reviews?
👉 Insight:

Quality vs revenue relationship
*/


SELECT review_score,ROUND(SUM(price)::numeric,2) as revenue
FROM order_reviews orr
JOIN olist_orders odd
ON orr.order_id=odd.order_id
JOIN order_items_dataset oid
ON odd.order_id=oid.order_id
GROUP BY 1
ORDER BY 2 DESC
-- Yes, Higher rating has generated higher revenue


SELECT 
    product_category_name,
    COUNT(DISTINCT odd.order_id) AS total_orders,
    COUNT(DISTINCT odd.order_id) FILTER (WHERE review_score < 2) AS bad_review_orders,
    ROUND(
        100.0 * COUNT(DISTINCT odd.order_id) FILTER (WHERE review_score < 2)
        / COUNT(DISTINCT odd.order_id),
        2
    ) AS bad_review_rate
FROM order_reviews orr
JOIN olist_orders odd
ON orr.order_id = odd.order_id
JOIN order_items_dataset oid
ON odd.order_id = oid.order_id
JOIN products_dataset pd
ON pd.product_id = oid.product_id
GROUP BY product_category_name
ORDER BY bad_review_rate DESC;

-- Shows which categories have the highest bad review percentage, not just count.

/*
🔁 Funnel Thinking ()
Find:
% orders delivered
% orders reviewed
Drop-offs
👉 Insight:
Where business is losing engagement
*/

WITH categorisation AS(
SELECT count(oos.*) as totalorders,
COUNT(*)FILTER(WHERE order_status='delivered') as deliverorders,
COUNT(*)FILTER(WHERE review_score is not null) as orderreviewed
FROM olist_orders oos
LEFT JOIN order_reviews ors
ON oos.order_id=ors.order_id
)
SELECT 100*(deliverorders::numeric/totalorders) AS  ordersdeliverepercentage,
100*(orderreviewed::NUMERIC/totalorders) as ordersreviewedpercentage
FROM categorisation


/*
Customer Segmentation 
Find:
High-value customers (top 10%)
Low-value customers
Frequent vs infrequent buyers
*/

SELECT os.customer_id, SUM(price) AS totalpurchase
from order_items_dataset oit
JOIN olist_orders os
ON oit.order_id=os.order_id
JOIN customers_dataset cs
ON os.customer_id=cs.customer_id
GROUP BY os.customer_id
ORDER BY 2 DESC



WITH customer_spend AS(
SELECT cs.customer_unique_id, SUM(price) AS totalpurchase
from order_items_dataset oit
JOIN olist_orders os
ON oit.order_id=os.order_id
JOIN customers_dataset cs
ON os.customer_id=cs.customer_id
GROUP BY cs.customer_unique_id
ORDER BY 2 DESC),
ranked AS
(
SELECT *, 
		NTILE(10) OVER (ORDER BY totalpurchase DESC) AS decile 
		FROM customer_spend
		)
-- SELECT SUM(totalpurchase) from ranked
SELECT * FROM ranked 
WHERE decile = 1;
-- Founded top 10%ile customers by total amount spent



WITH customer_spend AS(
SELECT cs.customer_unique_id, SUM(price) AS totalpurchase
from order_items_dataset oit
JOIN olist_orders os
ON oit.order_id=os.order_id
JOIN customers_dataset cs
ON os.customer_id=cs.customer_id
GROUP BY cs.customer_unique_id
ORDER BY 2 DESC),
ranked AS
(
SELECT *, 
		NTILE(10) OVER (ORDER BY totalpurchase DESC) AS decile 
		FROM customer_spend
		)
-- SELECT SUM(totalpurchase) from ranked
SELECT * FROM ranked 
WHERE decile = 10;
-- Founded botttom 10%ile customers by total amount spent
-- -------------------------



-- Customers jinne 2016 mein order kiya
SELECT cs.customer_unique_id 
FROM olist_orders o
JOIN customers_dataset cs
ON o.customer_id = cs.customer_id
WHERE EXTRACT(YEAR FROM order_placed_time) = 2016

INTERSECT

-- Customers jinne 2017 mein order kiya
SELECT cs.customer_unique_id 
FROM olist_orders o
JOIN customers_dataset cs
ON o.customer_id = cs.customer_id
WHERE EXTRACT(YEAR FROM order_placed_time) = 2017

INTERSECT

-- Customers jinne 2018 mein order kiya
SELECT cs.customer_unique_id 
FROM olist_orders o
JOIN customers_dataset cs
ON o.customer_id = cs.customer_id
WHERE EXTRACT(YEAR FROM order_placed_time) = 2018;

-- Result: There is only one customer who bought in all 3 years



-- Customers jinne order kiya but review nahi diya
SELECT customer_id FROM olist_orders
WHERE order_status = 'delivered'

EXCEPT

SELECT DISTINCT os.customer_id
FROM order_reviews orr
JOIN olist_orders os 
ON orr.order_id = os.order_id

-- Result:- Total 646 customers haven't given any reviews.



SELECT customer_city,max(order_delivered_customer_date-order_estimated_delivery_date) as longestdelay,
MAX(order_estimated_delivery_date-order_delivered_customer_date) as earlierthanestimated
FROM olist_orders oo
JOIN customers_dataset ct
ON oo.customer_id=ct.customer_id
GROUP BY customer_city
ORDER BY longestdelay

-- Negative period in longest_delay shows that, there is no delay in delivering an order in that city ('Best cities for us')
-- Negative value in earlierthanestimated shows that, in that particular city orders have never deliverd on time('Always after estimated date')






-- Final Insights
/*
Business grew rapidly from 329 orders in 2016 to 54,011 in 2018
Maximum new customers acquired in mid-2017
Best delivery — 146 days before estimated date
Worst delivery — 188 days after estimated date indicating operations failures.

São Paulo (SP) has the highest number of delayed orders.
Some cities show consistently late deliveries
There are logistics inefficiencies, especially region-specific.

Only 1 customer was active across all 3 years — extremely poor retention
Majority of customers are one-time buyers — repeat purchase rate is very low
646 delivered customers never left a review

5-star ratings are the most frequent
Higher ratings = Higher revenue —> investing in quality directly impacts growth
Credit card is the dominant payment method (both in usage and revenue contribution)
Top seller fulfilled 2,033 orders
