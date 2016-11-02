create table summary.policy_yearly_2015_j as
with s as (
  select
  jurisdiction_id,
  year,
  sum(condo_count) as count,
  sum(t_premium) as t_premium,
  sum(t_cov_bldg) as t_cov_bldg,
  sum(t_cov_cont) as t_cov_cont
  from summary.policy_monthly_summary_j s
  where year >=1994
  group by jurisdiction_id,year
),
j as (
 select jurisdiction_id,
 (st_area(st_transform(boundary,2163))/10000) as hectares,
 j_name10,
 j_statefp10,
 j_pop10,
 boundary
 from fima.jurisdictions
)
select
j.*,
year,
2015 as dollar_year,
count,
(t_premium*rate/hectares) as t_premium_p_ha,
(t_cov_bldg*rate/hectares) as t_cov_bldg_p_ha,
(t_cov_cont*rate/hectares) as t_cov_cont_p_ha
from s join j using (jurisdiction_id)
 join inflation i on (s.year=i.from_year)
where i.to_year=2015;

alter table summary.policy_yearly_2015_j
add primary key (jurisdiction_id,year);
