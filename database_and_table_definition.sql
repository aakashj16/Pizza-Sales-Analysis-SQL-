create database if not exists sales_analysis_project_db;

use sales_analysis_project_db;

create table if not exists pizza_type 
(
	pizza_type_id varchar(15) primary key,
    name_ varchar(50) unique not null,
    category varchar(10) not null,
    ingredients varchar(100) not null
);

create table if not exists pizzas
(
	pizza_id varchar(15) primary key,
    pizza_type_id varchar(15) not null,
    foreign key(pizza_type_id) references pizza_type (pizza_type_id)
        on delete cascade
        on update cascade,
    size varchar(5) not null,
    price decimal(5, 2) not null,
    constraint check_price check (price > 0)
);

create table if not exists orders
(
	order_id int auto_increment primary key,
    order_date date not null,
    order_time time not null
);

create table if not exists order_details
(
	order_details_id int auto_increment primary key,
    order_id int not null,
    foreign key (order_id) references orders (order_id)
        on delete cascade
        on update cascade,
    pizza_id varchar(15) not null,
    foreign key (pizza_id) references pizzas (pizza_id)
        on delete cascade
        on update cascade,
    quantity int not null,
    constraint check_quantity check (quantity > 0)
);