drop view  if exists vw_delay_by_region_mode;
drop table if exists fact_orders   cascade;
drop table if exists dim_products  cascade;
drop table if exists dim_customers cascade;

create table dim_customers as
select distinct
	"Customer Id", "Customer Fname", "Customer Lname", "Customer Email",
	"Customer Segment", "Customer City", "Customer State", "Customer Street",
	"Customer Country", "Customer Zipcode"
from datacosupplychaindataset;
create table dim_products as
select distinct
	"Product Card Id", "Product Name", "Product Price",
	"Product Category Id", "Category Name", "Department Id", "Department Name"
from datacosupplychaindataset;
create table fact_orders as
select
	"Order Id", "Order Item Id", "Order Customer Id",
	"Order Item Cardprod Id" as "Product Card Id",
	"order date (DateOrders)" as order_date_raw,
	"shipping date (DateOrders)" as ship_date_raw,
	"Order Region", "Order State", "Order City", "Order Country", "Market",
	"Shipping Mode", "Days for shipping (real)", "Days for shipment (scheduled)",
	"Delivery Status", "Late_delivery_risk", "Order Item Quantity",
	"Order Item Product Price", "Order Item Discount", "Order Item Discount Rate",
	"Sales", "Order Item Total", "Order Item Profit Ratio",
	"Order Profit Per Order", "Benefit per order"
from datacosupplychaindataset;
select "Customer Id", count(*) from dim_customers group by "Customer Id" having count(*) > 1;
select "Product Card Id", count(*) from dim_products group by "Product Card Id" having count(*) > 1;
alter table dim_customers add primary key ("Customer Id");
alter table dim_products add primary key ("Product Card Id");
alter table fact_orders add constraint fk_customer foreign key ("Order Customer Id") references dim_customers("Customer Id");
alter table fact_orders add constraint fk_product foreign key ("Product Card Id") references dim_products("Product Card Id");
select conname from pg_constraint where conrelid = 'dim_products' ::regclass and contype = 'p';
select
	c."Customer Segment",
	avg(f."Days for shipping (real)" - f."Days for shipment (scheduled)") as avg_delay
from fact_orders f
join dim_customers c on f."Order Customer Id" = c."Customer Id"
group by c."Customer Segment"
order by avg_delay desc;
select
	p."Department Name",
	count(*) as order_count,
	avg(f."Days for shipping (real)" - f."Days for shipment (scheduled)") as avg_delay
from fact_orders f
join dim_products p on f."Product Card Id" = p."Product Card Id"
group by p."Department Name"
order by avg_delay desc;
select
	c."Customer Segment", p."Department Name",
	avg(f."Days for shipping (real)" - f."Days for shipment (scheduled)") as avg_delay
from fact_orders f
join dim_customers c on f."Order Customer Id" = c."Customer Id"
join dim_products p on f."Product Card Id" = p."Product Card Id"
group by c."Customer Segment", p."Department Name"
order by avg_delay desc
limit 20;
create view vw_delay_by_region_mode as
select 
	"Order Region", "Shipping Mode",
	count(*) as order_count,
	avg("Days for shipping (real)" - "Days for shipment (scheduled)") as avg_delay
from fact_orders
group by "Order Region", "Shipping Mode"
order by avg_delay desc;
