use practice
-- we have importerd the data from csv file given

select * from pizza_sales;


-- total revenue
select cast(sum(total_price) as decimal(10,2)) as Total_Revenue from pizza_sales

-- to get monthly sales
select month(order_date) as Month, sum(total_price) as Total_monthly_sales from pizza_sales group by month(order_date) order by month(order_date)
;
with cte as (
select DATENAME(MONTH, order_date) as Month, month(order_date) as Month_number, cast(sum(total_price) as decimal(10,2)) as Total_monthly_sales 
from pizza_sales 
group by DATENAME(MONTH, order_date), month(order_date)
)
select Month, Total_monthly_sales
from cte
order by Month_number
;

-- quarterly sales
with cte as (
select DATENAME(quarter, order_date) as Quarter, cast(sum(total_price) as decimal(10,2)) as Total_quarterly_sales 
from pizza_sales 
group by DATENAME(quarter, order_date)
)
select Quarter, Total_monthly_sales
from cte
order by Quarter
;
-- weekly sales
-- datename(week, order_date) - returns week number as strinng, so it was not getting sorted acc to week number, so we used datepart
with cte as (
select datepart(WEEK, order_date) as Week, cast(sum(total_price) as decimal(10,2)) as Total_weekly_sales 
from pizza_sales 
group by datepart(week, order_date)
)
select Week, Total_weekly_sales
from cte
order by Week asc


-- average order value
with avg_order_value_cte as (
select order_id, cast(sum(quantity*unit_price) as decimal(10,2)) as total_order_value 
from pizza_sales
group by order_id
-- order by order_id
)
select cast(avg(total_order_value) as decimal(10, 2)) as avg_order_value from avg_order_value_cte 

-- Alternate
select cast(sum(total_price)/count(distinct order_id) as decimal(10,2)) as Avg_order_value from pizza_sales


-- total pizza sold
select sum(quantity) as Total_pizza_sold from pizza_sales

-- if we want it by pizza_id and pizza_size as well
select pizza_id, pizza_size, cast(total_price as decimal(10,2)) as total_price from pizza_sales

select distinct pizza_name, cast(sum(total_price) as decimal(10,2)) as t6otal_price from pizza_sales group by pizza_name

-- total number of orders
select count(distinct order_id) as total_orders from pizza_sales;

-- average pizza per order
-- here we have just rounded off the end result to 2 decimal places
select cast(sum(quantity)/count(distinct order_id) as decimal(5,2)) as Avg_pizza_per_order from pizza_sales
-- here it's done in a diff way to get the exact decimal values
select cast(cast(sum(quantity) as decimal(10,2))/cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) as Avg_pizza_per_order 
from pizza_sales

select order_id, sum(quantity) as no_of_pizza from pizza_sales group by order_id;

-------------============================----------------------=================================-------------------=========================
-- orders on daily basis to see any trend
select * from pizza_sales where order_date = '2015-01-01'

select order_date, count(distinct order_id) as total_orders, cast(sum(total_price) as decimal(10,2)) as Order_value 
from pizza_sales 
group by order_date
order by order_date

-- we use Datename() to get day name
select datename(weekday, order_date) as Day, count(distinct order_id) as total_orders, cast(sum(total_price) as decimal(10,2)) as Order_value 
from pizza_sales 
group by datename(weekday,order_date)
order by total_orders

-- to get monthly trend
select datename(month,order_date) as Month_Name, count(distinct order_id) as total_orders, cast(sum(total_price) as decimal(10,2)) as Order_value 
from pizza_sales 
group by datename(month,order_date)
order by total_orders


-- percentage of sales by pizza category
-- on the basis of sales amount
select pizza_category, 
cast(cast((sum(total_price)/(select sum(total_price) from pizza_sales )*100) as decimal(10,2)) as varchar)+ ' %' as PCT
-- needed to convert it into varchar so as to attach % sign with it
from pizza_sales
group by pizza_category

-- Alternate
with cte as (
select pizza_category, cast(sum(total_price) as decimal(10,2)) as category_amount,
(select cast(sum(total_price) as decimal(10,2)) from pizza_sales) as total_amount
from pizza_sales
group by pizza_category
)
select pizza_category, cast((qty_sold/total_quantity) as decimal(10,2))*100 as pct from cte



-- on the basis of sold quantities
select pizza_category, sum(quantity) as qty_sold
, (cast((cast(sum(quantity) as decimal(10,2))/(select cast(sum(quantity) as decimal(10,2)) from pizza_sales)) as decimal(10,2)) *100) as Pct
from pizza_sales 
group by pizza_category

-- Alternate
;
-- select * from pizza_sales
with cte as (
select pizza_category, cast(sum(quantity) as decimal(10,2)) as qty_sold, 
(select cast(sum(quantity) as decimal(10,2)) from pizza_sales) as total_quantity
from pizza_sales
group by pizza_category
)
select pizza_category, cast((qty_sold/total_quantity) as decimal(10,2))*100 as pct from cte


-- percentage of sales acc to pizza sie
select * from pizza_sales;
;
with cte as (
select 
case when pizza_size = 'S' then 'Small'
	 when pizza_size = 'M' then 'Medium'
	 when pizza_size = 'L' then 'Large'
	 when pizza_size = 'XL' then 'Extra Large'
	 when pizza_size = 'XXL' then 'Doule Extra Large'
end as Pizza_Size,
cast(sum(total_price) as decimal(10,2)) as sum_sales_size
, (select cast(sum(total_price) as decimal(10,2)) from pizza_sales) as overall_total_sales
from pizza_sales
group by pizza_size
)
select Pizza_Size, cast((sum_sales_size/overall_total_sales) as decimal(10,3))*100 as Pct
from cte
order by Pct desc







----------- =================== ------------------------  =========================     ---------------------    ==========================
----------- =================== ------------------------  =========================     ---------------------    ==========================
----------- =================== ------------------------  =========================     ---------------------    ==========================

-- top 5 pizza acc to revenue, total quantity, total orders

-- acc to revenue
select top 5 pizza_name, cast(sum(total_price) as decimal(10,2)) as revenue
from pizza_sales 
group by pizza_name
order by revenue desc

-- Alternate
;
with cte as (
select pizza_name, cast(sum(total_price) as decimal(10,2)) as total_sales, 
row_number() over (order by sum(total_price) desc) as rn
from pizza_sales 
group by pizza_name
-- order by total_sales
)
select * from cte where rn<=5


-- acc to quantity ordered
select top 5 pizza_name, sum(quantity) as total_quantity_ordered
from pizza_sales 
group by pizza_name
order by total_quantity_ordered desc


-- acc to quantity ordered
select top 5 pizza_name, count(distinct order_id) as total_orders
from pizza_sales 
group by pizza_name
order by total_orders desc


select * from pizza_sales


--- =================== --------------- ====================== ------------------------- ===================== ---------------

-- bottom 5 pizza acc to revenue, total quantity, total orders

-- acc to revenue
select top 5 pizza_name, cast(sum(total_price) as decimal(10,2)) as revenue
from pizza_sales 
group by pizza_name
order by revenue

-- acc to quantity ordered
select top 5 pizza_name, sum(quantity) as total_quantity_ordered
from pizza_sales 
group by pizza_name
order by total_quantity_ordered


-- acc to quantity ordered
select top 5 pizza_name, count(distinct order_id) as total_orders
from pizza_sales 
group by pizza_name
order by total_orders



