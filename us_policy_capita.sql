set search_path=us,summary,fima,public;

-- 1. annual per capita
drop table us.policy_yearly_llj_pop10;
create table us.policy_yearly_llj_pop10
as select
llj_id,
year,
ljp.pop10 as population,
count/ljp.pop10 as count_capita,
t_premium/ljp.pop10 as t_premium_capita,
t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
t_cov_cont/ljp.pop10 as t_cov_cont_capita,
(t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
extract(epoch from (year||'-01-01')::date) as epoch_start,
extract(epoch from (year||'-12-31')::date) as epoch_end,
lj.boundary
from summary.policy_yearly_2015_llj s
join fima.lljpolicy lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id)
where year>=1994 and year<=2014;

-- cd Downloads/Time_Manager/US_Annual_#policy_capita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Annual_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_Annual_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_premiumpolicy_capita.mp4

-- 2. monthly new per capita
drop table us.policy_monthlynew_2015_llj_pop10;
create table us.policy_monthlynew_2015_llj_pop10
as select
llj_id,
year,
month,
year - 1 as syear,
ljp.pop10 as population,
count/ljp.pop10 as count_capita,
t_premium/ljp.pop10 as t_premium_capita,
t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
t_cov_cont/ljp.pop10 as t_cov_cont_capita,
(t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
extract(epoch from (year||'-'||CAST(month AS VARCHAR(2))||'-01')::date) as epoch_start,
extract(epoch from ((year||'-'||CAST(month AS VARCHAR(2))||'-01')::date + interval '1 month' - interval '1 day') ) as epoch_end,
lj.boundary
from summary.policy_monthly_summary_2015_llj s
join fima.lljpolicy lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id);

-- cd Downloads/Time_Manager/US_monthlynew_#policy_capita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Monthly_new_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_monthlynew_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Monthly_new_premiumpolicy_capita.mp4

--3 daily new policy data in 2015 dollar value
drop table summary.policy_dailynew_summary_2015_llj;
create table summary.policy_dailynew_summary_2015_llj as
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
 join llgridpolicy g using (gis_longi,gis_lati)
 join fima.jurisdictions j using (jurisdiction_id)
 join fima.lljpolicy lj using (jurisdiction_id,llgrid_id)
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
from s join inflation i on (i.from_year=s.year)
where i.to_year=2015
order by 1,2,3,4,5;

alter table summary.policy_dailynew_summary_2015_llj
add primary key (llj_id,end_eff_dt, year,month,day);


--4 daily effective policy, rolling 12 months

drop table summary.policy_dailyeff_summary_2015_llj;
create table summary.policy_dailyeff_summary_2015_llj as 
WITH s AS (
  SELECT 
  b.llj_id, 
  SUM(b.count) AS scount, 
  SUM(b.t_premium) AS spremium,
  SUM(b.t_cov_bldg) AS st_cov_bldg,
  SUM(b.t_cov_cont) AS st_cov_cont,
  d.as_of_date AS date 
  FROM GENERATE_SERIES('1992-01-01'::timestamp, '2014-12-31'::timestamp, interval '1 day') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_summary_2015_llj b ON b.end_eff_dt <= d.as_of_date
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
  FROM GENERATE_SERIES('1992-01-01'::timestamp, '2014-12-31'::timestamp, interval '1 day') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_summary_2015_llj b ON b.end_eff_dt <= d.as_of_date
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

alter table summary.policy_dailyeff_summary_2015_llj alter column effdate type date;
  
--5 monthly effective policy, rolling 12 months
drop table summary.policy_monthlyeff_summary_2015_llj_pop10;
create table summary.policy_monthlyeff_summary_2015_llj_pop10 as
select
 llj_id,
 effdate,
 ljp.pop10 as population,
 count/ljp.pop10 as count_capita,
 t_premium/ljp.pop10 as t_premium_capita,
 t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
 t_cov_cont/ljp.pop10 as t_cov_cont_capita,
 (t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
 extract(epoch from effdate) as epoch_start,
 extract(epoch from (effdate + interval '1 month' - interval '1 day') ) as epoch_end,
 lj.boundary
from summary.policy_dailyeff_summary_2015_llj s
join fima.lljpolicy lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id)
where day ='01';






      
      
      
