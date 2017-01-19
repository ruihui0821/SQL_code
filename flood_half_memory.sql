Flood memory half-life

-- 1.1  daily new policy data in 2015 dollar value
drop table summary.policy_dailynew_2015;
create table summary.policy_dailynew_2015 as
with s as (
 select
 re_community,
 end_eff_dt,
 extract(year from end_eff_dt) as year,
 extract(month from end_eff_dt) as month,
 extract(day from end_eff_dt) as day,
 sum(condo_unit) as condo_count,
 sum(t_premium) as t_premium,
 sum(t_cov_bldg) as t_cov_bldg,
 sum(t_cov_cont) as t_cov_cont
 from public.allpolicy a
 group by 1,2,3,4,5
 order by 1,2,3,4,5)
select
s.re_community as cid,
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

alter table summary.policy_dailynew_2015
add primary key (cid,end_eff_dt);

--1.2 daily effective policy, rolling 12 months
drop table summary.policy_dailyeff_2015;
create table summary.policy_dailyeff_2015 as 
WITH s AS (
  SELECT 
  b.cid, 
  SUM(b.count) AS scount, 
  SUM(b.t_premium) AS spremium,
  SUM(b.t_cov_bldg) AS st_cov_bldg,
  SUM(b.t_cov_cont) AS st_cov_cont,
  d.as_of_date AS sdate 
  FROM GENERATE_SERIES('1994-01-01'::timestamp, '2015-01-01'::timestamp, interval '1 day') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_2015 b ON b.end_eff_dt < d.as_of_date
  GROUP BY b.cid, d.as_of_date
  ORDER BY b.cid, d.as_of_date),
e AS (
  SELECT 
  b.cid, 
  SUM(b.count) AS ecount,
  SUM(b.t_premium) AS epremium,
  SUM(b.t_cov_bldg) AS et_cov_bldg,
  SUM(b.t_cov_cont) AS et_cov_cont,
  d.as_of_date + interval '1 year' as edate 
  FROM GENERATE_SERIES('1993-01-01'::timestamp, '2014-01-01'::timestamp, interval '1 day') d (as_of_date)
  LEFT JOIN summary.policy_dailynew_2015 b ON b.end_eff_dt < d.as_of_date
  GROUP BY b.cid, d.as_of_date
  ORDER BY b.cid, d.as_of_date)
select
s.cid,
s.sdate- interval '1 day' as effdate,
s.scount - e.ecount as count,
s.spremium - e.epremium as premium,
s.st_cov_bldg - e.et_cov_bldg as t_cov_bldg,
s.st_cov_cont - e.et_cov_cont as t_cov_cont
from s 
join e on (s.cid = e.cid) and (s.sdate = e.edate)
order by s.cid, s.sdate;

alter table summary.policy_dailyeff_2015 alter column effdate type date;

alter table summary.policy_monthlyeff_2015
add primary key (cid,effdate);



select
  effdate,
  sum(count) as count,
  sum(premium) as premium
from summary.policy_dailyeff_2015_llj p
join fima.lljpolicy l on (p.llj_id = l.llj_id)
join fima.jurisdictions j on (l.jurisdiction_id = j.jurisdiction_id)
where j.j_cid in (select n.cid from fima.nation n where county = 'ALAMEDA COUNTY')
group by 1
order by 1;