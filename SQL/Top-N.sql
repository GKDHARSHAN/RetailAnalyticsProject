with cte as ( 
select o.region_id,o.employee_id, e.first_name, e.last_name, sum(o.total_amount) as total_revenue 
from orders o join employees e on o.employee_id = e.employee_id 
where o.order_status != 'Cancelled' 
group by o.employee_id,region_id),

another_cte as ( 
select region_id, employee_id, first_name, last_name, Total_revenue, 
	row_number() over (
		partition by region_id order by total_revenue desc) as ranking 
from cte)

select a.region_id,r.region_name, a.first_name, a.last_name, a.total_revenue, ranking 
from another_cte a 
join regions r on a.region_id = r.region_id 
where ranking = 1;
