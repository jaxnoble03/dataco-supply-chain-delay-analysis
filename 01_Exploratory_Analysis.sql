select count(*) from datacosupplychaindataset d ;
select distinct "Shipping Mode" from datacosupplychaindataset d ;
select distinct "Delivery Status" from datacosupplychaindataset d ;
select distinct "Order Region" from datacosupplychaindataset d ;
select
count(*) filter(where "order date (DateOrders)" is null) as null_order_date,
count(*) filter(where "shipping date (DateOrders)" is null) as null_ship_date
from datacosupplychaindataset;
select
"Order Region",
avg("Days for shipping (real)" - "Days for shipment (scheduled)") as avg_delay
from datacosupplychaindataset d 
group by "Order Region" 
order by avg_delay desc;
