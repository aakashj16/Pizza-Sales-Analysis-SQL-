-- sales performance overview: customer favourite pizzas
-- top 5 most sold pizzas in 2015
select
pt.name_ AS pizza_name, sum(od.quantity) as total_quantity_sold
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
group by pizza_name
order by total_quantity_sold desc
limit 5;

-- top 5 most revenue generating pizzas in 2015
select 
pt.name_ as pizza_name, round(sum(od.quantity * p.price), 2) as revenue_generated_USD
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
group by pizza_name
order by revenue_generated_USD desc
limit 5;

-- monthly trends
-- sales trend 2015
select
month_name, number_of_orders
from
(
	select 
	monthname(order_date) as month_name, month(order_date) AS month_, count(order_id) AS number_of_orders
	from orders
	group by month_name, month_
	order by month_ asc
) as x;

-- revenue trend 2015
select
month_name, revenue_generated_USD
from
(
	select 
	monthname(o.order_date) as month_name, month(o.order_date) as month_, round(sum(p.price * od.quantity), 2) as revenue_generated_USD
	from orders as o
	join order_details as od on o.order_id = od.order_id
	join pizzas as p on od.pizza_id = p.pizza_id
	join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
	group by month_name, month_
	order by month_ asc
) as x;

-- months with minimum and maximum revenue
-- minimum revenue
with cte as 
(
	select
	month_name, revenue_generated_USD
	from
	(
		select 
		monthname(o.order_date) as month_name, month(o.order_date) as month_, round(sum(p.price * od.quantity), 2) as revenue_generated_USD
		from orders as o
		join order_details as od on o.order_id = od.order_id
		join pizzas as p on od.pizza_id = p.pizza_id
		join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
		group by month_name, month_
		order by month_ asc
	) as x
)
select 
month_name as month_with_least_sales, revenue_generated_USD
from cte
where revenue_generated_USD = 
(
	select min(revenue_generated_USD)
    from cte
);

-- maximum revenue
with cte as 
(
	select
	month_name, revenue_generated_USD
	from
	(
		select 
		monthname(o.order_date) as month_name, month(o.order_date) as month_, round(sum(p.price * od.quantity), 2) as revenue_generated_USD
		from orders as o
		join order_details as od on o.order_id = od.order_id
		join pizzas as p on od.pizza_id = p.pizza_id
		join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
		group by month_name, month_
		order by month_ asc
	) as x
)
select 
month_name as month_with_highest_sales, revenue_generated_USD
from cte
where revenue_generated_USD = 
(
	select max(revenue_generated_USD)
    from cte
);

-- consumer behaviour
-- preferred pizza size
select 
p.size, sum(od.quantity) as number_of_pizza,
round((sum(od.quantity) * 100) / sum(sum(od.quantity)) over(), 2) as percentage_number_of_pizzas
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
group by p.size
order by number_of_pizza desc;

-- sales trend by week
select
dayname(order_date) as day_of_week, count(order_id) as number_of_orders,
round((count(order_id) * 100) / sum(count(order_id)) over(), 2) as percentage_total_orders
from orders
group by day_of_week
order by number_of_orders desc;

-- sales trend by pizza type
select
pt.name_ as pizza_name, count(o.order_id) as number_of_orders, 
round((count(o.order_id) * 100) / sum(count(o.order_id)) over(), 2) as percentage_total_orders
from orders as o
join order_details as od on o.order_id = od.order_id
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
group by pizza_name
order by number_of_orders desc;

-- sales trend by week and pizza type
select
dayname(o.order_date) as day_of_week, pt.name_ as pizza_name, count(o.order_id) as number_of_orders,
round((count(o.order_id) * 100) / sum(count(o.order_id)) over(), 2) as percentage_total_orders
from orders as o
join order_details as od on o.order_id = od.order_id
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
group by day_of_week, pizza_name
order by number_of_orders desc;

-- sales trend by hour
select
hour(o.order_time) as hour_, count(o.order_id) as number_of_orders,
round((count(o.order_id) * 100) / sum(count(o.order_id)) over(), 2) as percentage_number_of_orders
from orders as o
group by hour_
order by hour_;

-- revenue by hour
select
hour(o.order_time) as hour_, sum(p.price) as revenue_generated_USD,
round((sum(p.price) * 100)/ sum(sum(p.price)) over(), 2) as percentage_revenue_generated
from orders as o
join order_details as od on o.order_id = od.order_id
join pizzas as p on od.pizza_id = p.pizza_id
group by hour_
order by hour_;

-- top performing pizza
-- top selling pizza each month (by quantity)
select month_, pizza_name, quantity_sold 
from
(
	select
    month(o.order_date) as month_, pt.name_ as pizza_name, sum(od.quantity) as quantity_sold,
	rank() over(partition by month(o.order_date) order by sum(od.quantity) desc) ranking 
    from orders as o 
    join order_details as od on o.order_id = od.order_id 
    join pizzas as p on od.pizza_id = p.pizza_id 
    join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id 
    group by month_, od.pizza_id 
) as x 
where ranking = 1;   
   
-- top selling pizza each month (by revenue generated)
select 
month_name, pizza_name, revenue_generated_USD
from
(
	select 
	month(o.order_date) as month_, monthname(o.order_date) as month_name, pt.name_ as pizza_name, sum(p.price * od.quantity) as revenue_generated_USD,
	rank() over(partition by month(o.order_date) order by sum(p.price * od.quantity) desc) as ranking
	from orders as o
	join order_details as od on o.order_id = od.order_id
	join pizzas as p on od.pizza_id = p.pizza_id
	join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
	group by month_, month_name, pizza_name
) as x
where ranking = 1;

-- pizza category analysis
-- number of orders by category
select 
pt.category, sum(od.quantity) as number_of_orders,
round((sum(od.quantity) * 100) / sum(sum(od.quantity)) over(), 2) as percentage_total_orders
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by number_of_orders desc;

-- revenue by category
select
pt.category, sum(p.price * od.quantity) as revenue_generated_USD,
round((sum(p.price * od.quantity) * 100) / sum(sum(p.price * od.quantity)) over(), 2) as percentage_revenue_generated
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by revenue_generated_USD desc;

-- revenue by category and months
select
month_name, category, revenue_generated_USD, percentage_revenue_generated
from
(
	select
	month(o.order_date) as month_, monthname(o.order_date) as month_name, pt.category, sum(od.quantity * p.price) as revenue_generated_USD,
	round((sum(od.quantity * p.price) * 100) / sum(sum(od.quantity * p.price)) over(), 2) as percentage_revenue_generated,
	dense_rank() over(partition by month(o.order_date) order by month(o.order_date), sum(od.quantity * p.price) desc) as ranking
	from orders as o
	join order_details as od on o.order_id = od.order_id
	join pizzas as p on od.pizza_id = p.pizza_id
	join pizza_type as pt on p.pizza_type_id = pt.pizza_type_id
	group by month_, month_name, category
) as x;

-- correlation: price vs sales
-- do cheaper pizza perform better?
select 
case
	when p.price between 9.75 and 18.5 then "Low-Range Pizza"
    when p.price between 18.51 and 27.25 then "Medium-Range Pizza"
    when p.price between 27.26 and 36.00 then "High-Range Pizza"
end as price_range,
sum(od.quantity) as total_quantity_sold,
round((sum(od.quantity) * 100) / sum(sum(od.quantity)) over(), 2) as percentage_quantity_sold
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
group by price_range
order by total_quantity_sold desc;

-- order size analysis
-- number of pizzas per order
select
sum(od.quantity) / count(o.order_id) as average_pizza_per_order
from orders as o
join order_details as od on o.order_id = od.order_id;