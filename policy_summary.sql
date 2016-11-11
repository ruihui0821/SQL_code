set search_path=summary,fima,public;

-- 1.
drop table summary.policy_yearly_2015_j;
create table summary.policy_yearly_2015_j as
with s as (
  select
  jurisdiction_id,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as count,
  sum(t_premium) as t_premium,
  sum(t_cov_bldg) as t_cov_bldg,
  sum(t_cov_cont) as t_cov_cont
  from public.allpolicy a
  join fima.jurisdictions j using (jurisdiction_id)
  group by 1,2
  order by 1,2
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
s.year,
s.count,
s.t_premium*rate as t_premium,
s.t_cov_bldg*rate as t_cov_bldg,
s.t_cov_cont*rate as t_cov_cont
from s join j using (jurisdiction_id)
join inflation i on (s.year=i.from_year)
where i.to_year=2015;

alter table summary.policy_yearly_2015_j
add primary key (jurisdiction_id,year);

-- 1.1 (not making yet) daily new policy data in 2015 dollar value
drop table summary.policy_dailynew_2015_j;
create table summary.policy_dailynew_2015_j as
with s as (
 select
 jurisdiction_id,
 end_eff_dt,
 extract(year from end_eff_dt) as year,
 extract(month from end_eff_dt) as month,
 extract(day from end_eff_dt) as day,
 sum(condo_unit) as condo_count,
 sum(t_premium) as t_premium,
 sum(t_cov_bldg) as t_cov_bldg,
 sum(t_cov_cont) as t_cov_cont
 from public.allpolicy a
 join fima.jurisdictions j using (jurisdiction_id)
 group by 1,2,3,4,5
 order by 1,2,3,4,5)
select
s.jurisdiction_id,
s.end_eff_dt,
s.year,
s.month,
s.day,
condo_count as count,
t_premium*rate as t_premium,
t_cov_bldg*rate as t_cov_bldg,
t_cov_cont*rate as t_cov_cont,
to_year as dollars_in
from s join inflation i on (i.from_year=s.year)
where i.to_year=2015
order by 1,2,3,4,5;

alter table summary.policy_dailynew_2015_j
add primary key (jurisdiction_id,end_eff_dt, year,month,day);


-- 2. 
drop table summary.policy_yearly_2015_llj;
create table summary.policy_yearly_2015_llj as
with s as (
 select
 llj_id,
 extract(year from end_eff_dt) as year,
 sum(condo_unit) as count,
 sum(t_premium) as t_premium,
 sum(t_cov_bldg) as t_cov_bldg,
 sum(t_cov_cont) as t_cov_cont
 from public.allpolicy a
 join llgridpolicy g using (gis_longi,gis_lati)
 join fima.jurisdictions j using (jurisdiction_id)
 join fima.lljpolicy lj using (jurisdiction_id,llgrid_id)
 group by 1,2
 order by 1,2
),
j as (
 select llj_id,
 boundary,
 hectares
 from fima.lljpolicy)
select
j.*,
s.year,
s.count,
s.t_premium*rate as t_premium,
s.t_cov_bldg*rate as t_cov_bldg,
s.t_cov_cont*rate as t_cov_cont
from s join j using (llj_id)
join inflation i on (s.year=i.from_year)
where i.to_year=2015;

alter table summary.policy_yearly_2015_llj add primary key (llj_id,year);

-- 2.1  daily new policy data in 2015 dollar value
drop table summary.policy_dailynew_2015_llj;
create table summary.policy_dailynew_2015_llj as
with s as (
 select
 llj_id,
 end_eff_dt,
 extract(year from end_eff_dt) as year,
 extract(month from end_eff_dt) as month,
 extract(day from end_eff_dt) as day,
 sum(condo_unit) as condo_count,
 sum(t_premium) as t_premium,
 sum(t_cov_bldg) as t_cov_bldg,
 sum(t_cov_cont) as t_cov_cont
 from public.allpolicy a
 --join llgridpolicy g using (gis_longi,gis_lati)
 --join fima.jurisdictions j using (jurisdiction_id)
 --join fima.lljpolicy lj using (jurisdiction_id,llgrid_id)
 group by 1,2,3,4,5
 order by 1,2,3,4,5)
select
s.llj_id,
s.end_eff_dt,
s.year,
s.month,
s.day,
condo_count as count,
t_premium*rate as t_premium,
t_cov_bldg*rate as t_cov_bldg,
t_cov_cont*rate as t_cov_cont,
to_year as dollars_in
from s join public.inflation i on (i.from_year=s.year)
where i.to_year=2015
order by 1,2,3,4,5;

alter table summary.policy_dailynew_2015_llj
add primary key (llj_id,end_eff_dt);

--2.2 daily effective policy, rolling 12 months
-- not making yet
drop table summary.policy_dailyeff_2015_llj;
create table summary.policy_dailyeff_2015_llj as 
WITH s AS (
  SELECT 
  b.llj_id, 
  SUM(b.count) AS scount, 
  SUM(b.t_premium) AS spremium,
  SUM(b.t_cov_bldg) AS st_cov_bldg,
  SUM(b.t_cov_cont) AS st_cov_cont,
  d.as_of_date AS date 
  FROM GENERATE_SERIES('1994-01-01'::timestamp, '2014-12-31'::timestamp, interval '1 day') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_2015_llj b ON b.end_eff_dt <= d.as_of_date where b.llj_id = 1
  GROUP BY b.llj_id, d.as_of_date
  ORDER BY b.llj_id, d.as_of_date desc),
e AS (
  SELECT 
  b.llj_id, 
  SUM(b.count) AS ecount,
  SUM(b.t_premium) AS epremium,
  SUM(b.t_cov_bldg) AS et_cov_bldg,
  SUM(b.t_cov_cont) AS et_cov_cont,
  d.as_of_date + interval '1 year' as date 
  FROM GENERATE_SERIES('1994-01-01'::timestamp, '2014-12-31'::timestamp, interval '1 day') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_2015_llj b ON b.end_eff_dt <= d.as_of_date where b.llj_id = 1
  GROUP BY b.llj_id, d.as_of_date
  ORDER BY b.llj_id, d.as_of_date desc)
select
s.llj_id,
s.date as effdate,
extract(day from date) as day,
s.scount - e.ecount as count,
s.spremium - e.epremium as premium,
s.st_cov_bldg - e.et_cov_bldg as t_cov_bldg,
s.st_cov_cont - e.et_cov_cont as t_cov_cont
from s 
full outer join e using (llj_id, date)
order by s.llj_id, s.date desc;

alter table summary.policy_dailyeff_2015_llj alter column effdate type date;


--2.3 monthly effective policy, rolling 12 months
drop table summary.policy_monthlyeff_2015_llj;
create table summary.policy_monthlyeff_2015_llj as 
WITH s AS (
  SELECT 
  b.llj_id, 
  SUM(b.count) AS scount, 
  SUM(b.t_premium) AS spremium,
  SUM(b.t_cov_bldg) AS st_cov_bldg,
  SUM(b.t_cov_cont) AS st_cov_cont,
  d.as_of_date AS sdate 
  FROM GENERATE_SERIES('1994-01-01'::timestamp, '2015-01-01'::timestamp, interval '1 month') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_2015_llj b ON b.end_eff_dt < d.as_of_date
  GROUP BY b.llj_id, d.as_of_date
  ORDER BY b.llj_id, d.as_of_date),
e AS (
  SELECT 
  b.llj_id, 
  SUM(b.count) AS ecount,
  SUM(b.t_premium) AS epremium,
  SUM(b.t_cov_bldg) AS et_cov_bldg,
  SUM(b.t_cov_cont) AS et_cov_cont,
  d.as_of_date + interval '1 year' as edate 
  FROM GENERATE_SERIES('1993-01-01'::timestamp, '2014-01-01'::timestamp, interval '1 month') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_2015_llj b ON b.end_eff_dt < d.as_of_date
  GROUP BY b.llj_id, d.as_of_date
  ORDER BY b.llj_id, d.as_of_date)
select
s.llj_id,
s.sdate- interval '1 day' as effdate,
s.scount - e.ecount as count,
s.spremium - e.epremium as premium,
s.st_cov_bldg - e.et_cov_bldg as t_cov_bldg,
s.st_cov_cont - e.et_cov_cont as t_cov_cont
from s 
full outer join e on (s.llj_id = e.llj_id) and (s.sdate = e.edate)
order by s.llj_id, s.sdate;

alter table summary.policy_monthlyeff_2015_llj alter column effdate type date;

alter table summary.policy_monthlyeff_2015_llj
add primary key (llj_id,effdate);

-- Check if data exists for all months, and the correlation as well
select p.effdate, corr(p.count, j.income) 
from summary.policy_monthlyeff_2015_llj p, fima.lljpolicy_income j 
where p.llj_id = j.llj_id 
group by 1 order by 1;

-- 3. NOT MAKING YET
drop table summary.policy_monthly_summary_llgrid;
create table summary.policy_monthly_summary_llgrid as
select
llgrid_id,
extract(year from end_eff_dt) as year,
extract(month from end_eff_dt) as month,
sum(condo_unit) as condo_count,
sum(t_premium) as t_premium,
sum(t_cov_bldg) as t_cov_bldg,
sum(t_cov_cont) as t_cov_cont
from public.allpolicy a
join llgrid g using (gis_longi,gis_lati)
left join fima.jurisdictions j using (jurisdiction_id)
left join fima.lljpolicy lj using (jurisdiction_id,llgrid_id)
where lj is null
group by 1,2,3
order by 1,2,3;
alter table summary.policy_monthly_summary_llgrid add primary key (llgrid_id,year,month);

