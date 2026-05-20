-- 1) Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS Total_Orders FROM orders;

-- 2) Calculate the total revenue generated from pizza sales.
SELECT ROUND(sum(order_details.quantity * pizzas.price),2) AS Total_Revenue 
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id;

-- 3) Identify the highest-priced pizza. 
SELECT pizza_types.name,pizzas.price FROM pizzas
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC LIMIT 1;

-- Using Subquery 
SELECT pizza_types.name,pizzas.price FROM pizzas
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
WHERE price = (SELECT MAX(price) FROM pizzas);

-- 4)Identify the most common pizza size ordered.
SELECT count(order_details.quantity) AS Total_Quantity,pizzas.size AS Pizza_Size FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size 
ORDER BY count(order_details.quantity) DESC LIMIT 1; 

-- 5) List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,SUM(order_details.quantity) AS quantity FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_typeS.name 
ORDER BY quantity DESC LIMIT 5;

-- 6) Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT SUM(order_details.quantity) AS Total_Quantity, pizza_types.category AS Pizza_Category FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category;

-- 7) Determine the distribution of orders by hour of the day.
SELECT hour(order_time) AS Hours ,count(order_id) AS Total_Orders FROM orders
GROUP BY Hours;

-- 8) Join relevant tables to find the category-wise distribution of pizzas.
SELECT category,count(name) FROM pizza_types
GROUP BY category;

-- 9) Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(Quantity),2) FROM 
(SELECT orders.order_date,sum(order_details.quantity) AS Quantity FROM orders
JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS order_quantity;

-- 10) Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name ,
SUM(order_details.quantity * pizzas.price) AS Total_revenue
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name ORDER BY Total_revenue DESC LIMIT 3;

-- 11) Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
concat(Round((SUM(order_details.quantity * pizzas.price)/ (SELECT ROUND(sum(order_details.quantity * pizzas.price),2) AS Total_Revenue 
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id))*100,2),"%") AS Percentage_of_Total_Revenua 
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- 12)Analyze the cumulative revenue generated over time.
SELECT order_date,SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(SELECT orders.order_date,
ROUND(SUM(pizzas.price * order_details.quantity),2)AS revenue
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
JOIN orders
ON order_details.order_id = orders.order_id
GROUP BY orders.order_date) AS sales;

-- 13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT pizza_names,category,revenue
FROM
(SELECT pizza_names,revenue,category,RANK()OVER(PARTITION BY category 
ORDER BY revenue DESC)AS rn
FROM
(SELECT pizza_names,revenue,pizza_types.category AS category
FROM pizza_types
JOIN 
(SELECT pizza_types.name AS pizza_names, SUM(pizzas.price * order_details.quantity)AS revenue
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name)AS a
ON pizza_types.name = pizza_names)AS b)AS c
WHERE rn <= 3


















