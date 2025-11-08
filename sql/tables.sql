create database superstore;
use superstore;
CREATE TABLE temp_superstore (
    OrderID VARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(100),
    CustomerID VARCHAR(50),
    Segment VARCHAR(50),
    Country VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100),
    Region VARCHAR(50),
    ProductID VARCHAR(50),
    Category VARCHAR(100),
    SubCategory VARCHAR(100),
    ProductName VARCHAR(255),
    Sales DECIMAL(12,2),
    Quantity INT,
    Discount DECIMAL(6,3),
    Profit DECIMAL(12,2)
);
CREATE TABLE Customers(
    customer_Id VARCHAR(100) NOT NULL PRIMARY KEY,
    segment VARCHAR(150)
);
CREATE TABLE product_d (
    product_Id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255)
);
CREATE TABLE address (
    Location_Id INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(50),
    UNIQUE(country, state, city, region)
);
CREATE TABLE orders (
    order_Id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(100),
    customer_Id VARCHAR(50),
    Location_Id INT,
    FOREIGN KEY (customer_Id) REFERENCES Customers(customer_Id),
    FOREIGN KEY (Location_Id) REFERENCES address(Location_Id)
);
CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_Id VARCHAR(50),
    product_Id VARCHAR(50),
    sales DECIMAL(12,2),
    discount DECIMAL(6,3),
    profit DECIMAL(12,2),
    quantity INT,
    FOREIGN KEY (order_Id) REFERENCES orders(order_Id),
    FOREIGN KEY (product_Id) REFERENCES product_d(product_Id)
);
SET sql_notes = 0;
SET sql_warnings = 0;

INSERT IGNORE INTO Customers (customer_Id, segment)
SELECT DISTINCT CustomerID, Segment
FROM temp_superstore;


INSERT IGNORE INTO product_d (product_Id, category, sub_category, product_name)
SELECT DISTINCT ProductID, Category, SubCategory, ProductName
FROM temp_superstore;


INSERT IGNORE INTO address (country, state, city, region)
SELECT DISTINCT Country, State, City, Region
FROM temp_superstore;


INSERT IGNORE INTO orders (
    order_Id, order_date, ship_date, ship_mode, customer_Id, Location_Id
)
SELECT DISTINCT
    OrderID,
    OrderDate,
    ShipDate,
    ShipMode,
    CustomerID,
    NULL AS Location_Id
FROM temp_superstore;

INSERT IGNORE INTO order_details (
    order_Id, product_Id, sales, discount, profit, quantity
)
SELECT DISTINCT
    OrderID,
    ProductID,
    Sales,
    Discount,
    Profit,
    Quantity
FROM temp_superstore;

SET sql_notes = 1;
SET sql_warnings = 1;
SELECT COUNT(*) AS total_customers FROM Customers;
SELECT COUNT(DISTINCT CustomerID) AS unique_customers FROM temp_superstore;

# Monthly Sales and Profit Trend
select
date_format(o.order_date,'%y-%m') as month,
round(sum(od.sales),2) as total_sales,
round(sum(od.profit),2) as total_profit
from orders o
join order_details od on o.order_Id = od.order_Id
group by date_format(o.order_date,'%y-%m')
order by month;

# Yearly Performance Summary
select
year(o.order_date) as year,
round(sum(od.sales),2) as total_sales,
round(sum(od.profit),2) as total_profit,
count(distinct o.order_Id) as total_orders
from orders o
join order_details od on o.order_id = od.order_Id
group by year(o.order_date)
order by year;

# Top 20 Most Profitable Products
select
p.product_name,
p.sub_category,
round(sum(od.sales),2) as total_sales,
round(sum(od.profit),2) as total_profit
from order_details od
join product_d p on od.product_Id = p.product_Id
group  by p.product_name, p.sub_category
order by total_profit desc
limit 20;

UPDATE orders o
JOIN temp_superstore t ON o.Order_Id = t.OrderID
JOIN address l 
  ON t.City = l.City 
  AND t.State = l.State 
  AND t.Region = l.Region 
  AND t.Country = l.Country
SET o.Location_Id = l.Location_Id
where o.Location_Id is null;

# Category and Region Performance
select
a.region,
p.category,
round(sum(od.sales), 2) as total_sales,
round(sum(od.profit), 2) as total_profit
from order_details od
inner join orders o  on od.order_Id = o.order_Id
inner join address a on o.Location_Id = a.Location_Id
inner join product_d p on od.product_Id = p.product_Id
group by a.region, p.category
order by a.region asc, total_sales desc;

# Discount Impact on Profit
select
round(od.discount, 2) as discount_rate,
round(sum(od.sales), 2) as total_sales,
round(sum(od.profit), 2) as total_profit,
count(*) as no_of_orders
from order_details od
group by round(od.discount, 2)
order by discount_rate;

 # Top Sub-Categories by Sales in Each Region
 select
 a.region,
 p.sub_category,
 round(sum(od.sales), 2) as total_sales
 from orders o
 join order_details od on o.order_Id = od.order_Id
 join product_d p on od.product_Id = p.product_Id
 join address a on o.Location_Id = a. Location_Id
 group by a.region, p.sub_category
 order by a.region, total_sales desc;
 



select * from order_details;
select * from address;
select * from orders;
select * from product_d;
select * from Customers;
















