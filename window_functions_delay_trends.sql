select "order date (DateOrders)" from datacosupplychaindataset limit 5;
select 
	"Order Region",
	avg("Days for shipping (real)" - "Days for shipment (scheduled)") as avg_delay,
	rank() over (order by avg("Days for shipping (real)" - "Days for shipment (scheduled)") desc) as delay_rank
from datacosupplychaindataset
group by "Order Region";
select 
	"Shipping Mode",
	avg("Days for shipping (real)" - "Days for shipment (scheduled)") as avg_delay,
	rank() over (order by avg("Days for shipping (real)" - "Days for shipment (scheduled)") desc) as delay_rank
from datacosupplychaindataset
group by "Shipping Mode";
select 
	"Category Name",
	avg("Days for shipping (real)" - "Days for shipment (scheduled)") as avg_delay,
	rank() over (order by avg("Days for shipping (real)" - "Days for shipment (scheduled)") desc) as delay_rank
from datacosupplychaindataset
group by "Category Name";
with monthly_delay as (
	select 
		DATE_TRUNC('month', TO_TIMESTAMP("order date (DateOrders)", 'FMMM/FMDD/YYYY HH24:MI')) as order_month,
		avg("Days for shipping (real)" - "Days for shipment (scheduled)") as avg_delay
		from datacosupplychaindataset 
		group by order_month
	)
	select 
		order_month,
		avg_delay,
		avg_delay - lag(avg_delay) over (order by order_month) as change_from_prior_month
		from monthly_delay 
		order by order_month;