select base_flood, sum(condo_unit) as count, sum(t_cov_bldg+t_cov_cont) as coverage 
from p2014 
where substr(flood_zone, 1, 1) = 'V' 
group by 1 order by 1;

select base_flood, sum(condo_unit) as count, sum(t_cov_bldg+t_cov_cont) as coverage 
from p2014  
group by 1 order by 1;
