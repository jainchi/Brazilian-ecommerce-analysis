create table geolocation
(
geolocation_zip_code_prefix	bigint ,
geolocation_lat float 	,
geolocation_lng	float,
geolocation_city varchar(55),
geolocation_state varchar(25)
);



create table customers
(
customer_id	varchar(55) primary key,
customer_unique_id varchar(55),
customer_zip_code_prefix bigint,
customer_city	varchar(55),
customer_state varchar(45)
);




CREATE TABLE categories(
product_category_name VARCHAR(150)	,
product_category_name_english VARCHAR(150)
);



create table sellers
(
seller_id varchar(65) primary key,
seller_zip_code bigint,
seller_city varchar(55),
seller_state varchar(25)
);


create table orders
(
order_id	varchar(55) primary key,
customer_id	varchar(55)references customers(customer_id),
order_status varchar(25),
order_purchase_timestamp	timestamp,
order_approved_at	 timestamp,
order_delivered_carrier_date timestamp,
order_delivered_customer_date	 timestamp,
order_estimated_delivery_date	timestamp
);



create table products 
(
product_id	VARCHAR(55) PRIMARY KEY,
product_category_name	VARCHAR(55) references categoproduct_category_name,
product_name_lenght	BIGINT,
product_description_lenght 	BIGINT,
product_photos_qty	BIGINT,
product_weight_g	BIGINT,
product_length_cm	BIGINT,
product_height_cm	BIGINT,
product_width_cm BIGINT
);


create table order_items
(
	order_id varchar(55) references orders(order_id),
	order_item_id int8	not null,
	product_id	varchar(55) references products (product_id),
	seller_id	varchar(65) references sellers(seller_id),
	shipping_limit_date	timestamp,
	price float	,
	freight_value float
);



CREATE TABLE payments
(
order_id varchar(55) references orders(order_id),
payment_sequential	int,
payment_type	varchar(25),
payment_installments	int,
payment_value float
);



CREATE TABLE reviews 
(
review_id	varchar(65) ,
order_id	 varchar(55) references orders(order_id),
review_score float,
review_comment_title varchar(55),
review_comment_message	varchar(255),
review_creation_date timestamp,
review_answer_timestamp timestamp
);











SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM customers;
SELECT * FROM order_items;
SELECT * FROM payments;
SELECT * FROM reviews ;
SELECT * FROM categories;
SELECT * FROM geolocation;
SELECT * FROM orders;


-- Checking in which column there are missing values 
SELECT count(*) FROM orders

SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_status) AS order_status_not_null,
    COUNT(order_purchase_timestamp) AS order_placed_time_not_null,
    COUNT(order_approved_at) AS order_approved_at_not_null,
	COUNT(order_delivered_carrier_date) AS order_delivered_carrier_date_not_null,
	COUNT(order_delivered_customer_date) AS order_delivered_customer_date_not_null,
	COUNT(order_estimated_delivery_date) AS order_estimated_delivery_date_not_null
FROM orders;


/*-- output:-
Missing values were present in some columns, but are very less approx 3k out of 99441 rows.
Since the proportion is relatively low, it is unlikely to have a significant impact on the analysis.
We should not delete these null values, because I believe that this is not any kind of mistake it is just in a half-way process and will be
enterd in record soon.
*/


-- Checking distinct values in the order_status column
SELECT DISTINCT order_status from orders

-- Outcome. Total 8 type of status are there in order_status column



 
-- Q1.How much order have placed in total by year

SELECT extract(year from order_purchase_timestamp) as yer,
count(order_id) as total_orders FROM ORDERS
group by 1
-- Outcome. In Year 2016 total '329' orders are place, In year 2017 total '45101' are placed and in 2018 maximum '54011 'orders have been placed.


-- Q2. Find the Differnce in day&time between a customer has placed ordered and received the order(max and min both)

	SELECT customer_id,min(order_delivered_customer_date - order_purchase_timestamp) as min_timdiff ,
	max(order_delivered_customer_date - order_purchase_timestamp) as max_timediff
	FROM ORDERS o
	where order_delivered_customer_date is not null
	group by 1
	
	-- it is for each customer
	or 
	
	SELECT min(order_delivered_customer_date - order_purchase_timestamp) as min_timdiff ,
	max(order_delivered_customer_date - order_purchase_timestamp) as max_timediff
	FROM ORDERS o
	where order_delivered_customer_date is not null
-- Outcome.> Maximum duration between a customer has placed an order and receives it is (209 days+15hrs) and minimum is(12hr 48 minutes approx)


-- Q3. Find the Differnce in day&time between the estimated product delivery and has actually been received.
	
	SELECT min(order_estimated_delivery_date -order_delivered_customer_date) ,
	max (order_estimated_delivery_date -order_delivered_customer_date)
	FROM ORDERS
		where order_delivered_customer_date is not null


-- Outcome. The 1st result is a very big win for us, we have delivered product 146 day before the estimated date, but
-- The second result is quite disappointing, it's coming (-188 days), which means we had taken 188 days extra after the estimated delivery date.



-- Q4. Anlayse how many product are there in each category.

	SELECT c.product_category_name,count(distinct product_id) as total_prod_count FROM categories c
	left join products p
	on c.product_category_name=p.product_category_name
	group by 1

-- Q.5 How many distinct seller's city are there in data?
	select distinct seller_city from sellers

-- Outcome. There are 611 different seller_city in the dataset


-- Q.6.Find sellers count by city and tell in which city seller is maximum and where is minimum
	
	select seller_city,count(*) as totalsellers from sellers
	group by 1
	order by 2 desc



--Q.7. Check the count of unique customer from each state
	select 
	trim(customer_state),
	count(distinct customer_unique_id) as totalcount 
	from customers
	group by 1
	order by 2 desc

-- We have customers from total of 27 states, with the maximum number of customers from 'SP' 


-- Q.8. Find the city with the maximum number of customers and check from how many distinct cities customers are from.

	select customer_city,count(distinct customer_unique_id) as totalcount  from customers
	group by 1
	order by 2 desc
-- In our dataset customers belongs to total 4119 different cities, where sao paulo holds most count. 



-- Q.9. FIND COUNT BY order_item_id?

	SELECT order_item_id,count(*) as total_cnt FROM order_items
	group by 1
	order by 1 
--- Maximum products sold are of order_item_id '1' with count of 98.6k


--Q.10. Find order count of all sellers

	select s.seller_id,count(distinct order_id) as totalorders from sellers s left join  order_items oe
	on s.seller_id = oe.seller_id
	group by 1
	order by 2 desc
---- Maximum order count by a seller among all is 1854


-- Q.11. Check which order_item_id has generated maximum revenue
	select order_item_id, sum(price) as total_revenue from order_items
	group by order_item_id 
	order by 2 desc
---- Outcome. order_item_id "1" has generated maximum revenue



						--------- Basic analysis done here,now moving next a little deep -----------



-- Ques.12. Top 5 sellers by revenue

	SELECT s.seller_id, sum(price) as total_rev
	FROM sellers s
	LEFT JOIN order_items oe on s.seller_id = oe.seller_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5;



-- Ques.13. Average order value per seller

	SELECT s.seller_id, avg(price) as avg_rev
	FROM sellers s
	LEFT JOIN order_items oe on s.seller_id = oe.seller_id
	GROUP BY 1
	ORDER BY 2 DESC;



	
-- Ques.14. Seller vs city performance

	SELECT * FROM
	(
	SELECT seller_city,s.seller_id,sum(price) as total_revenue ,
	Dense_rank() OVER(PARTITION BY seller_city ORDER BY sum(price) DESC) as ranking 
	from sellers s
	left join order_items oe on s.seller_id = oe.seller_id
	GROUP BY 1,2
	ORDER BY 1,3 DESC
	)
	where ranking<6;
		



-- Ques 15. Find the top 2 Customers in each State by TotalPurchase


		
	WITH total as
	(
	SELECT customer_state,customer_unique_id,sum(price) as totalpurchase 
	FROM orders o
	JOIN customers c
	ON o.customer_id = c.customer_id
	JOIN order_items o3
	ON o.order_id=o3.order_id
	GROUP BY 1,2
	),
	rankingbytotal AS
	(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_state ORDER BY totalpurchase DESC) as rankbyrowno
	from total
	)
	SELECT * FROM rankingbytotal
	WHERE rankbyrowno<3;


/*
	“I used the price column from the order_items table to calculate purchase,
	as it represents the product value only. Using the order_payments table would include additional charges like freight,
	which were intentionally excluded from this analysis.”
					*/


---------------
SELECT * FROM payments
WHERE order_id='b81ef226f3fe1789b1e8b2acac839d17'

SELECT * FROM order_items
WHERE order_id='b81ef226f3fe1789b1e8b2acac839d17'
-- Checked what actually payment_value contains in order_payments_dataset(price+freight)







-- Q.16.Find top 2 customers for each sellers


SELECT * FROM(

	with customer_total as(
		SELECT s.seller_id, c.customer_id,SUM(price) as total_spent from
		sellers s
		JOIN order_items oe on s.seller_id=oe.seller_id
		JOIN orders o on oe.order_id=o.order_id
		JOIN customers c on o.customer_id = c.customer_id
		GROUP BY s.seller_id, c.customer_id
	)
	SELECT *,RANK() OVER(PARTITION BY seller_id ORDER BY total_spent DESC ) rnk
	from customer_total
	order by seller_id
	)
	WHERE rnk <3
-- OUTCOME Have founded top customer for each seller




/*
“I used the price column from the order_items table to calculate revenue,
as it represents the product value only. Using the order_payments table would include additional charges like freight,
which were intentionally excluded from this analysis.”
*/




-- 17. Monthly Revenue Trend

	WITH monthly_revenue as(
		SELECT extract(year from order_purchase_timestamp) as yer,
		EXTRACT(month from order_purchase_timestamp) as months ,SUM(price) as revenue_by_month
		FROM orders o
		JOIN order_items oe on o.order_id = oe.order_id
		GROUP by 1,2
		ORDER by 1,2
		)
		SELECT *,lAG(revenue_by_month) OVER(ORDER BY yer, months) as last_month_revenue,
		(revenue_by_month - LAG(revenue_by_month) OVER(ORDER BY yer, months))/LAG(revenue_by_month) OVER(ORDER BY yer, months) as trend
		FROM monthly_revenue
	
-- Above query shows monthly trend ignoring 'partition by year'





-- 18. Late Delivery Rate  

	SELECT extract(year from order_purchase_timestamp)as yer,
	avg(order_delivered_customer_date- order_estimated_delivery_date )as avg_delay_time
	FROM orders
	where (order_delivered_customer_date- order_estimated_delivery_date)>interval '00:00:00'
	group by 1

	-------or--------


with late_ordered as
	(
	SELECT count(*) as total_delayed
	FROM orders
	where (order_delivered_customer_date- order_estimated_delivery_date)>interval '00:00:00'
	)
	select 
	100.0*total_delayed/(	SELECT count(*) as total_delayed FROM orders) as "delay%"
	from late_ordered

-- Approx 8% of the ordered orders had delivered after the estimated delivery date





-- 19. Top 5 Revenue Categories

	select c.product_category_name,sum(price) as rev
	from categories c
	join products p 
	on c.product_category_name=p.product_category_name
	join order_items oe
	on p.product_id = oe.product_id
	group by 1
	order by 2 desc 



-- select count(distinct order_id) from orders




	
-- 20. Repeat vs One-time Customers

WITH  order_grouping as
		(
		SELECT  customer_unique_id,count(distinct order_id) totalcnt
		FROM customers c 
		JOIN orders o
		on c.customer_id=o.customer_id
		GROUP by 1
		),
								
	 customer_cnt as
	 	(
		SELECT COUNT(*) AS cnt FROM order_grouping
		)
		
		SELECT  
		100.0*(SELECT COUNT(*)FROM order_grouping WHERE totalcnt>1) /cnt as repeat_percent
		FROM customer_cnt


									---or---

	
	SELECT customer_type, count(*) from
	(
	SELECT ct.customer_unique_id,count(os.order_id),
	CASE WHEN COUNT(os.order_id) > 1 THEN 'Repeat Customer'ELSE 'One-time Customer' END AS customer_type
	FROM customers ct
	join orders os
	ON ct.customer_id=os.customer_id
	GROUP BY 1
	) AS customer_summary
	GROUP by 1
	-- In our business repeat customers are very less currently in comparison of One-time customers



	
	
-- Q.21.  GIVE ME THE MOST EXPENSIVE PRODUCT IN EACH CATEGORY

	select * from(
	select
		trim(product_category_name) as category_name,p.product_id,
		price,
		row_number() over(partition by product_category_name order by price desc) rn 
	from products p 
	join order_items oe
	on p.product_id=oe.product_id
	)
		where rn=1
		
	-- maximum price among products of a particular category
	




-- Q.22.GIve me total transactions for each customer , total money they have spent and their last purchase date

	select
		customer_unique_id ,
		count(o.order_id) as totaltransactions,
		sum(price) as total_purchase ,
		max(order_purchase_timestamp) as last_purchased_at
	from customers c
	join orders o on c.customer_id=o.customer_id
	join order_items oe on o.order_id = oe.order_id
	group by 1

-- Founded total purchase, count of transactions, last purchase date

	


-- Q.23. Which sellers has maximum delayed deliveries?

	SELECT s.seller_id ,count(distinct o.order_id) as total_late_orders
		FROM orders o
		join order_items oe on o.order_id = oe.order_id
		join sellers s on oe.seller_id = s.seller_id
		where (order_delivered_customer_date- order_estimated_delivery_date)>interval '00:00:00'
	group by 1
	order by 2 desc

-- 4a3ca9315b744ce9f8e9374361493884 has maximum delayed deliveries
	

-- Q.24  Group customers by:First purchase month

	WITH mycte1 as
(
	SELECT customer_unique_id,EXTRACT(MONTH FROM (	MIN(order_purchase_timestamp)	)	) mnth  
	FROM customers c 
	JOIN orders o on c.customer_id = o.customer_id
	GROUP BY 1
	)
		SELECT mnth, COUNT(*) as total_cnt from mycte1 
		GROUP BY 1
		ORDER BY 2 DESC
				
--------- Group customers by:First purchase month



/*
25. ⭐ Review vs Revenue 
Do higher ratings count → more sales?,
Which sellers/categories have good/bad reviews?
👉 Insight:

Quality vs revenue relationship
*/


	select 
	review_score,
	count(distinct review_id) as totalreviews, 
	sum(price) as total_revenue ,AVG(price) as avg_revenue
	from reviews r
	join orders o on r.order_id = o.order_id  
	join order_items oe on o.order_id = oe.order_id
	group by review_score
	order by 3 desc
	
-- Yes, Higher rating has generated higher revenue
-- No, Higher rating count does not mean higher avergae revenue


	select review_score,count(distinct s.seller_id) as total_sellers 
	from reviews r 
	join orders o on r.order_id = o.order_id 
	join order_items oe on o.order_id = oe.order_id
	join sellers s on oe.seller_id =s.seller_id
	group by 1


-- How many sellers fall into each review score



	SELECT 
	    s.seller_id,
	    COUNT(DISTINCT r.review_id) AS total_reviews,
	    AVG(r.review_score) AS avg_rating
	FROM reviews r
	JOIN orders o 
	    ON r.order_id = o.order_id
	JOIN order_items oi 
	    ON o.order_id = oi.order_id
	JOIN sellers s 
	    ON oi.seller_id = s.seller_id
	GROUP BY s.seller_id
	ORDER BY avg_rating desc;


--Have calculated average rating for each seller in the dataset




-- Q.26 
-- Which categories have the highest bad review percentage, not just count ?-- consider [1,2] as bad review

	With mycte1 as
	(
		select product_category_name,review_score,
		count(distinct review_id) as totalcount
		from reviews r 
		join orders o on r.order_id = o.order_id 
		join order_items oe on o.order_id = oe.order_id
		join products p on oe.product_id = p.product_id
		where review_score in(1,2)
		group by 1,2
						)
	select
			product_category_name, 
			sum(totalcount) as total_bad_reviews, 
			( select sum(totalcount) from mycte1 )	as totalreview , 
			100.0* (	sum(totalcount) /( select sum(totalcount) from mycte1 )	) as bad_reviewpercent
	from mycte1 
	group by 1 
	order by 4 desc
	
-- Shows which categories have the highest bad review percentage, not just count.


/*Q27
🔁 Funnel Thinking ()
Find:
-- % orders delivered
-- % orders reviewed

-- Where business is losing engagement
-- */



with total_making as(
	select count(*) filter(where review_id is null) as not_reviewed, 
	count(*) filter(where order_delivered_customer_date is null) as total_undelivered,
	count(*) as totals
	from orders o
	left join reviews r on o.order_id = r.order_id
)
select
	(not_reviewed/ totals)* 100 as unreviewd_prcnt ,
	(total_undelivered/totals)*100 as undeliver_prcnt
from total_making







/*Q.28.
Customer Segmentation 
Find:
High-value customers (top 10%)
Low-value customers
*/

select * from(
	select customer_unique_id , sum(price) as total_purchase,ntile(10) over(order by sum(price) desc) as under_percentile
	from customers c
	join orders o on c.customer_id = o.customer_id
	join order_items oe on o.order_id = oe.order_id
	group by 1
	)
	where under_percentile in (1,10)






-- Q.29. customer who purchase in all 3 years(2016,2017,2018)

	select * from customers c
	where customer_unique_id in(
		
		select c.customer_unique_id
			from customers c
			join orders o on c.customer_id = o.customer_id
			where extract(year from order_purchase_timestamp)=2016
		)	-- Customers jinne 2016 mein order kiya
		
		and customer_unique_id in
		(
			select c.customer_unique_id
			from customers c
			join orders o on c.customer_id = o.customer_id
			where extract(year from order_purchase_timestamp)=2017
	)-- Customers jinne 2017 mein order kiya
		
		and customer_unique_id in
		(
			select c.customer_unique_id
			from customers c
			join orders o on c.customer_id = o.customer_id
			where extract(year from order_purchase_timestamp)=2018
	)-- Customers jinne 2018 mein order kiya



-- 32ea3bdedab835c3aa6cb68ce66565ef
-- 32ea3bdedab835c3aa6cb68ce66565ef
	
			---- or ----

			
			SELECT cs.customer_unique_id 
			FROM orders o
			JOIN customers cs
			ON o.customer_id = cs.customer_id
			WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2016
			
			INTERSECT
			
			-- Customers jinne 2017 mein order kiya
			SELECT cs.customer_unique_id 
			FROM orders o
			JOIN customers cs
			ON o.customer_id = cs.customer_id
			WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2017
			
			INTERSECT
			
			-- Customers jinne 2018 mein order kiya
			SELECT cs.customer_unique_id 
			FROM orders o
			JOIN customers cs
			ON o.customer_id = cs.customer_id
			WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2018;
			
			-- Result: There is 1 customer who bought in all 3 years
				

-- Q.30. GIve me all those customers who have not given any reviews

	
	select  c.customer_unique_id, count(review_id) as total_reviews
	from customers c
	left join orders o on c.customer_id = o.customer_id
	left join reviews r on o.order_id = r.order_id
	WHERE order_status = 'delivered'
	group by 1
	having  count(review_id)=0		or		count(review_id) is null


	

	-----or--------

				SELECT distinct customer_unique_id
				FROM orders
				join customers c
				on orders.customer_id = c.customer_id
				WHERE order_status = 'delivered'
						
				EXCEPT
						
				SELECT DISTINCT customer_unique_id
				FROM reviews orr
				JOIN orders os 
				ON orr.order_id = os.order_id
				JOIN customers c
				on os.customer_id = c.customer_id
	


-- Result:- Total 603 customers haven't given any reviews.



Q.31.------ RFM Analysis ----Recency, frequency and monetary

-- Note: (select max(order_purchase_timestamp) from orders) using this because we cannot use current_date as the data is older



SELECT
	customer_unique_id,
	max(order_purchase_timestamp)as last_order,
	(select max(order_purchase_timestamp) from orders) - max(order_purchase_timestamp) as days_since_last_purchase,
	count(distinct o.order_id) as total_orders ,
	sum(price) as total_value
	FROM customers c
	join orders o on c.customer_id = o.customer_id 
	join order_items oe on o.order_id = oe.order_id
group by 1
order by 5 desc


-- (select max(order_purchase_timestamp) from orders) 



--Q.32.Delivery Performance by Seller -------==========>>>>>>>>>>>>>


SELECT
	s.seller_id, 
	count(distinct o.order_id) as total_deliveries,
	count(distinct o.order_id) filter(where (order_estimated_delivery_date - order_delivered_customer_date) <interval '00:00:00') as late_deliveries,
	
	100.0*count(distinct o.order_id) filter(where (order_estimated_delivery_date - order_delivered_customer_date) <interval '00:00:00')
										/	count(distinct o.order_id) as "late%",
	count(distinct o.order_id) filter(where (order_estimated_delivery_date - order_delivered_customer_date) >=interval '00:00:00') as ontime_deliveries,
	
	100.0*count(distinct o.order_id) filter(where (order_estimated_delivery_date - order_delivered_customer_date) >=interval '00:00:00')
									/	count(distinct o.order_id) as "ontime_delivery%"
									
FROM sellers s join order_items oe on s.seller_id = oe.seller_id
join orders o on oe.order_id = o.order_id 
group by 1





Q.33.-- Calculate Monthly Moving Average Revenue


with extraction as(		
	SELECT
		
		EXTRACT(year from order_purchase_timestamp	) as yer ,
		extract(month from order_purchase_timestamp) as mnth,
		sum(price) as revenues
		FROM orders o 
		join order_items oe on o.order_id = oe.order_id
		group by 1,2
)
select
		yer,mnth,revenues,
		avg(revenues)  over(order by yer, mnth rows between 2 preceding and current row) as rnavg
		from extraction
		







-- Q.34. Seller Ranking within State ⭐⭐⭐⭐⭐

	select 
	seller_state,s.seller_id  , sum(price)as total_rev,
	dense_rank() over(partition by seller_state order by sum(price) desc) as rnk 
	FROM sellers s
	left join order_items oe on s.seller_id = oe.seller_id
	left join orders o on oe.order_id = o.order_id 
	group by 1,2




-- -- DAYS			Sales				RANK()			DENSE_Rank()   ROW_NUMBER()

-- 	Day1		1000				1				1					1
-- 	Day2		1500				2				2					2
-- 	Day3		1700				3				3					3
-- 	Day4		1700				3				3					4
-- 	Day5		1700				3				3					5
-- 	Day6		1800				6				4					6
-- 	Day7		1900				7				5					7





-- Q.35. --- Payment Behaviour ---


select
	payment_type,
	sum(payment_value) as total_payment,
	count(p.order_id) as total_transactions,
	avg(payment_installments) as avg_installment,
	avg(payment_value) as avg_payment_amount
from payments p 
join orders o on p.order_id =o.order_id
where order_status ='delivered'
group by 1










	
Q.36.--. Pareto Analysis (80/20 Rule) --  Do the top 20% of products contribute around 80% of revenue?

-- You'll need:

-- SUM(price)
-- Window functions


with cte1 as
	(
		select p.product_id, sum(price) as total_revenue 
		from products p join order_items oe 
		on p.product_id = oe.product_id 
		group by 1 order by 2 desc
					)
	, cte2 as
	(
		select *,ntile(5) over (order by total_revenue desc ) tile_group
		from cte1 
			)
		select 100.0* sum(total_revenue) / (select sum(total_revenue) from cte1	) as contributed
		from cte2 
		where tile_group=1

	

-- Top 20% products contributes approx 75% of revenue




	WITH revenue AS (
	    SELECT
	        product_id, SUM(price) AS total_revenue
	    FROM order_items
	    GROUP BY product_id
	),
	pareto AS (
	    SELECT
	        product_id,  total_revenue, 
			SUM(total_revenue) OVER (   ORDER BY total_revenue DESC  ) AS running_revenue,
	        SUM(total_revenue) OVER () AS total_revenue_all
	    FROM revenue
	)
	
	SELECT
	    product_id,
	    total_revenue,
	        100.0 * running_revenue / total_revenue_all AS cumulative_revenue_percent
	FROM pareto
	ORDER BY total_revenue DESC;
	
-- Top 8536 products are contributing 80% of revenue


-- 8536/32951= 26





	
-- Q.37.Find sellers count by city and tell in which city seller is maximum and where is minimum

SELECT seller_city, COUNT(*) as citysellercount
FROM sellers
WHERE seller_city IS NOT NULL
GROUP BY 1
order by 2 desc


CREATE EXTENSION IF NOT EXISTS unaccent;

SELECT 
    unaccent(TRIM(LOWER(seller_city))) AS cleaned_city,
    COUNT(*) AS citysellercount
FROM sellers
WHERE seller_city IS NOT NULL
GROUP BY unaccent(TRIM(LOWER(seller_city)))
ORDER BY citysellercount DESC;


	









-- Queries that exist in version 2 but not in version 1
-- Written with version 1 table names (orders, customers, sellers, order_items, payments, reviews)
-- Numbered Q.38 onward so they can be pasted at the end of version 1








-- Q.38. Average order value per seller

SELECT seller_id,
       ROUND(SUM(price)::NUMERIC, 2) AS total_revenue,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND((SUM(price) / COUNT(DISTINCT order_id))::NUMERIC, 2) AS avg_order_value
FROM order_items
GROUP BY 1
ORDER BY 4 DESC;








-- Q.39 Number of written comments per review score

SELECT review_score, COUNT(review_comment_message) AS total_comments
FROM reviews
WHERE review_comment_message IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;








-- Q.40. Seller city spelling variants (check for "sao paulo" duplicates)
SELECT seller_city, COUNT(*) AS cnt
FROM sellers
WHERE LOWER(seller_city) LIKE '%sao paulo%'
GROUP BY seller_city
ORDER BY cnt DESC;







-- Q.41. Longest delay and earliest delivery per customer city
-- Positive longest_delay = delivered late; negative = never late in that city

SELECT c.customer_city,
       MAX(o.order_delivered_customer_date - o.order_estimated_delivery_date) AS longest_delay,
       MAX(o.order_estimated_delivery_date - o.order_delivered_customer_date) AS earliest_delivery,
	   MIN(o.order_delivered_customer_date-o.order_estimated_delivery_date) AS earliest_delivery
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY longest_delay;






-- Q.42. Bad review rate per category (score 1 and 2), not just count
SELECT p.product_category_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       COUNT(DISTINCT o.order_id) FILTER (WHERE r.review_score <= 2) AS bad_review_orders,
       ROUND(100.0 * COUNT(DISTINCT o.order_id) FILTER (WHERE r.review_score <= 2)
             / COUNT(DISTINCT o.order_id), 2) AS bad_review_rate
FROM reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY bad_review_rate DESC;












-- Q.42. Top 10% customers by total spend (uses customer_unique_id)
WITH customer_spend AS (
    SELECT c.customer_unique_id, SUM(oi.price) AS total_purchase
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
),
ranked AS (
    SELECT *, NTILE(10) OVER (ORDER BY total_purchase DESC) AS decile
    FROM customer_spend
)
SELECT * FROM ranked WHERE decile = 1;







-- Q.43. New customers by first purchase year and month
WITH first_purchase AS (
    SELECT c.customer_unique_id, MIN(o.order_purchase_timestamp) AS first_order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY 1
)
SELECT EXTRACT(YEAR FROM first_order_date) AS year,
       EXTRACT(MONTH FROM first_order_date) AS month,
       COUNT(*) AS new_customers
FROM first_purchase
GROUP BY 1, 2
ORDER BY 1, 2;




-- Q.44. Bad review rate per category (score 1 and 2), not just count
SELECT p.product_category_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       COUNT(DISTINCT o.order_id) FILTER (WHERE r.review_score <= 2) AS bad_review_orders,
       ROUND(100.0 * COUNT(DISTINCT o.order_id) FILTER (WHERE r.review_score <= 2)
             / COUNT(DISTINCT o.order_id), 2) AS bad_review_rate
FROM reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY bad_review_rate DESC;









-- 45. Does late delivery lower review scores?

select * from reviews
join orders o
on o.r





-----1. Orders increased significantly from 2016 to 2018.
-----2.Around 8% of delivered orders were delivered later than the estimated delivery date.
	
-----3. São Paulo (SP) has the largest customer base.
-----4. São Paulo also has the highest number of sellers.
	
-----5. Most customers made only one purchase, indicating an opportunity to improve customer retention.
-----6. A few product categories generated the highest share of revenue.
-----7. Revenue is concentrated among a relatively small group of top-performing sellers.
	
-----8. Orders with higher review scores were associated with higher revenue.
-----9. Credit cards were the most commonly used payment method and generated the highest revenue .
-----10. Monthly revenue generally increased over time, although some months showed temporary declines.

