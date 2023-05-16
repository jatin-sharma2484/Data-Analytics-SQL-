// TABLE OF DIFFERENT ITEMS WITH THEIR PRICE-->
create table product(
 product_id int , product_name text , price int);

 insert into product values(1, 'p1', 980);
 insert into product values(2, 'p2', 870);
 insert into product values(3, 'p3', 330);

 select *from product;
 
//TABLE OF USERS WITH THEIR SIGNUP DATES--> 
 create table users(
 user_id int , signup_date text);

 insert into users values(1, '02-09-2014');
 insert into users values(2, '15-01-2015');
 insert into users values(3, '11-04-2014');

 select *from users;
 
 //TABLE OF GOLD-USERS WITH THEIR SIGNUP DATES-->
 create table goldusers_signup(
 user_id int , gold_signup_date date
 );

 insert into goldusers_signup values(1, '09-22-2017');
 insert into goldusers_signup values(3, '04-21-2017');

 select *from  goldusers_signup;
 
//TABLE OF SALES--> 
 create table sales(
 user_id int, created_date date, product_id int);

 insert into sales values(1, '04-19-2017', 2);
 insert into sales values(3, '12-18-2019', 1);
 insert into sales values(2, '07-20-2020', 3);
 insert into sales values(1, '10-23-2019', 2);
 insert into sales values(1, '03-19-2018', 3);
 insert into sales values(3, '12-20-2016', 2);
 insert into sales values(1, '11-09-2016', 1);
 insert into sales values(1, '05-20-2016', 3);
 insert into sales values(2, '09-24-2017', 1);
 insert into sales values(1, '03-11-2017', 2);
 insert into sales values(1, '03-11-2016', 1);
 insert into sales values(3, '11-10-2016', 1);
 insert into sales values(3, '12-07-2017', 2);
 insert into sales values(3, '12-15-2016', 2);
 insert into sales values(2, '11-08-2017', 2);
 insert into sales values(2, '09-10-2018', 3);

 select *from sales;
 
 --------------------------------------------------------------------------------------------------------------
 1. What is the total amount spent by each customer on zomato?
 
 select user_id, sum(price) as total_amount_spent from product
 left join sales
 on product.product_id = sales.product_id
 group by user_id;
 ---------------------------------------------------------------------------------------------------------------
 2. How many days has each customer visited zomato?
 select user_id , count(distinct created_date) as no_of_days_visited from sales group by user_id;
 ----------------------------------------------------------------------------------------------------------------
 3. What is the most purchased item on the menu and how  many times it was purchased by all customers?
 ## MOST PURCHASED ITEM.......
 select top 1 product_id  from sales group by product_id
 order by count(product_id) desc;


 ## NO. OF TIMES IT WAS PURCHASED BY ALL CUSTOMERS........
 select user_id , count(product_id) as no_of_times_purchased from sales where product_id = 
 (select top 1 product_id  from sales group by product_id
 order by count(product_id) desc)
 group by user_id;
 ------------------------------------------------------------------------------------------------------------------
 4. Which item was the most popular for each customer?
 select *from
 (select *,rank() over(partition by user_id order by no_of_times_purchased desc) as position from
 (select user_id, product_id, count(product_id) as no_of_times_purchased from sales
 group by user_id, product_id)a)b
 where position = 1;
 --------------------------------------------------------------------------------------------------------------------
 5. Which item was purchased first by the customer after they became a member?
 select *from
 (select a.* , rank() over(partition by user_id order by created_date) as position from
 (select sales.user_id,sales.created_date, sales.product_id , goldusers_signup.gold_signup_date from goldusers_signup
 inner join sales on goldusers_signup.user_id = sales.user_id
 and created_date >= gold_signup_date)a)b
 where position = 1;
 ---------------------------------------------------------------------------------------------------------------------
 6. Which item was purchased just before the customer became a member?
 select *from
 (select a.* , rank() over(partition by user_id order by created_date desc)as position from
 (select sales.user_id,sales.created_date, sales.product_id , goldusers_signup.gold_signup_date from goldusers_signup
 inner join sales on goldusers_signup.user_id = sales.user_id
 and created_date <= gold_signup_date)a)b
 where position = 1;
 ----------------------------------------------------------------------------------------------------------------------
 7. What is the total orders and amount spent for each member before they became a member?
 select user_id, count(product_id)as total_orders, sum(price)as total_amt_spent from
 (select a.*, product.price from
 (select sales.user_id,sales.created_date,sales.product_id , goldusers_signup.gold_signup_date from goldusers_signup
 inner join sales on goldusers_signup.user_id = sales.user_id
 and created_date <= gold_signup_date)a
 inner join product on a.product_id = product.product_id)b
 group by user_id;
------------------------------------------------------------------------------------------------------------------------
8. If buying each product generates points for eg 5rs=2 zomato points and each product has different purchasing points 
   for eg for p1 5rs=1 zomato point , for p2 10rs=5 zomato points and for p3 5rs=1 zomato point,
   calculate points collected by each customers and for which product most points have been given till now?
   
## POINTS COLLECTED BY EACH CUSTOMERS.......
select e.*, total_price/points as total_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id, c.product_id, sum(c.price) as total_price from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c
group by user_id, product_id)d)e;

## MOST POINTS.......
select * from
(select *, rank() over(order by total_no_of_points desc) as position from
(select f.product_id, sum(f.total_points) as total_no_of_points from
(select e.*, total_price/points as total_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id, c.product_id, sum(c.price) as total_price from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c
group by user_id, product_id)d)e)f
group by product_id)g)h where position = 1;
--------------------------------------------------------------------------------------------------------------------------
9. In the first one year after a customer joins the gold program (including their join date) irrespective of what the
   customer has purchased they earn 5 zomato points for every 10rs spent. Who earned more; 1 or 3 and what was their 
   points earnings in the first year?

select c.*, d.price*0.5 as total_points_earned from
(select a.user_id, a.created_date, a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.user_id = b.user_id and created_date>=gold_signup_date
and created_date<=DATEADD(year, 1, gold_signup_date))c
inner join product d on c.product_id=d.product_id;
