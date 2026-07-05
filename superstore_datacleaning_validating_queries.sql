
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Ecommerce Sales Analysis
-- Analyst: Allan Jigi Mathew
-- Tool: MySql 8.0
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Database and table setup

create database ecommerce_sales_analysis;
use ecommerce_sales_analysis;
create table superstore_sales(row_id INT,order_id VARCHAR(20),order_date varchar(20),ship_date varchar(20),ship_mode VARCHAR(20),customer_id VARCHAR(20),customer_name VARCHAR(100),segment VARCHAR(20),country VARCHAR(50),city VARCHAR(50),state VARCHAR(50), postal_code VARCHAR(10),region VARCHAR(20), product_id VARCHAR(50), category VARCHAR(20), subcategory VARCHAR(20), product_name VARCHAR(200),sales DECIMAL(10,2), quantity INT, discount DECIMAL(4,2), profit DECIMAL(10,2));

-- load csv using load data infile

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/superstore.csv'
INTO TABLE superstore_sales
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(row_id, order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
 segment, country, city, state, postal_code, region, product_id, category,
 subcategory, product_name, sales, quantity, discount, profit);
 
 -- Check if the all the rows are there using max and min rows 
 select max(row_id), min(row_id) from superstore_sales;
 
 -- Check the count of the total rows in the dataset
select count(*) as total_rows from superstore_sales;

-- check the total row_id, non duplicate row_id, max and minimum row_id
 select count(*),count(distinct row_id), min(row_id), max(row_id) from superstore_sales;
 
 -- Verify the data 
 select * from superstore_sales;
 
 -- To add new column 'order_date_new' and 'ship_date_new' as date
 alter table superstore_sales
 add column order_date_new date,
 add column ship_date_new date;
 
 -- To export the values from 'order_date' and 'ship_date' to 'order_date_new' and 'ship_date_new' and to convert the dates from strings
 update superstore_sales set order_date_new=str_to_date(order_date,"%m/%d/%Y"),
 ship_date_new=str_to_date(ship_date,"%m/%d/%Y") where row_id>0;
 set sql_safe_updates=1;
 
 -- To show the updated 'order_date_new' and 'ship_date_new'
 select order_date, order_date_new, ship_date, ship_date_new from superstore_sales limit 5;
 
 -- To check if any missing values for 'order_date_new' and 'ship_date_new'
 select count(*) from superstore_sales where order_date_new is NULL and ship_date_new is NULL;
 
 -- To drope column 'order_date' and 'ship_date'
 alter table superstore_sales drop column order_date, drop column ship_date;
 describe superstore_sales;

-- To remname 'order_date_new' and 'shipe_date_new' to original names in the csv
 alter table superstore_sales rename column order_date_new to order_date, rename column ship_date_new to ship_date;
 
 -- To select first 5 row_id, order_date, ship_date 
 select row_id, order_date,ship_date from superstore_sales limit 5;
 
 
select order_id, product_id, count(*) from superstore_sales group by order_id, product_id having count(*)>1; 

-- Check for blank/whitespace text fields
select 
sum(case when trim(customer_name)='' then 1 else 0 end) as blank_customer_name,
sum(case when trim(city)='' then 1 else 0 end) as city_blank,
sum(case when trim(state)='' then 1 else 0 end) as state_blank,
sum(case when trim(product_name)='' then 1 else 0 end) as product_blank,
sum(case when trim(ship_mode)='' then 1 else 0 end) as ship_blank from superstore_sales;

-- Check for invalid numerical values
select
sum(case when sales<=0 then 1 else 0 end) as sales_negative,
sum(case when quantity<=0 then 1 else 0 end) as quantity_negative,
sum(case when discount<0 and discount>1 then 1 else 0 end) as discount_negative,
sum(case when profit=NULL then 1 else 0 end) as profit_negative from superstore_sales;

-- Check text consistency in categorical columns 
select distinct category from superstore_sales;
select distinct region from superstore_sales;
select distinct segment from superstore_sales;
select distinct ship_mode from superstore_sales;

select * from superstore_sales where order_id='CA-2016-129714' and product_id='OFF-PA-10001970';

-- Check Overall KPIs
select round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit)/sum(sales)*100,2) as profit_sales_margin,
count(distinct order_id) as total_orders,
round(sum(sales)/ count(distinct order_id),2) as avg_order_value,
sum(quantity) as total_quantity from superstore_sales;

-- Check Yearly Sales
select year(order_date) as order_year,
round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit,
round(sum(profit)/sum(sales)*100,2) as profit_sales_margin_pr,
count(distinct order_id) total_orders,
round(sum(sales)/count(distinct order_id),2) as avg_order_value from superstore_sales group by order_year order by order_year; 

-- YOY Growth Rate
select year(order_date) as order_year, sum(sales) as total_sales, sum(profit) as total_profit,
round((sum(sales)-LAG(sum(sales)) over (order by year(order_date)))/LAG(sum(sales)) over (order by year(order_date))*100,2) as sales_growth_pct,
round((sum(profit)-LAG(sum(profit)) over (order by year(order_date)))/LAG(sum(profit)) over (order by year(order_date))*100,2) as profit_growth_pct
from superstore_sales group by order_year order by order_year;

-- Monthly Sales
select year(order_date) as order_year, month(order_date) as order_month, monthname(order_date) as month_name, round(sum(sales),2) as monthly_sales_total, round(sum(profit),2) as monthly_profit_total, round(sum(profit)/sum(sales)*100,2) as profit_sales_margin, count(distinct order_id) as total_orders, round(sum(sales)/count(distinct order_id),2) as avg_order_value
from superstore_sales group by order_year,order_month,month_name order by order_year, order_month;

-- Regional Sales
select region, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit, round(sum(profit)/sum(sales)*100,2) as profit_sales_margin, count(distinct order_id) as total_orders, round(sum(sales)/count(distinct order_id),2) as avg_order_value from 
superstore_sales group by region order by total_sales desc;

-- Category Sales
select category, subcategory, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit, round(sum(profit)/sum(sales)*100,2) as profit_sales_margin, count(distinct order_id) as total_orders, round(sum(sales)/count(distinct order_id),2) as avg_order_value
from superstore_sales group by category, subcategory order by total_sales desc;

-- Top 10 Porducts
select product_name,category,subcategory,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,sum(quantity) as total_quantity
from superstore_sales group by product_name,category,subcategory order by total_sales desc limit 10;

-- Bottom 10 Products 
select product_name,category,subcategory,round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit, sum(quantity) as total_quantity
from superstore_sales group by product_name, category, subcategory having sum(profit)<0 order by total_profit asc limit 10;

-- Segment Sales
select segment, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit, round(sum(profit)/sum(sales)*100,2) as profit_margin_pct, count(distinct order_id) as total_orders, round(sum(sales)/count(distinct order_id),2) as avg_order_value
from superstore_sales group by segment order by total_sales desc;

-- Shipping Sales
select ship_mode, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit, round(sum(profit)/sum(sales)*100,2) as profit_margin_pct, count(distinct order_id) as total_order, round(sum(sales)/count(distinct order_id),2) as avg_order_value
from superstore_sales group by ship_mode order by total_sales desc;  

-- State Sales
select state, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit, round(sum(profit)/sum(sales)*100,2) as profit_margin_pct, count(distinct order_id) as total_order, round(sum(sales)/count(distinct order_id),2) as avg_order_value
from superstore_sales group by state order by total_sales desc; 
