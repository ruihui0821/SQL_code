set search_path=summary,fima,public,us;

-- adding llj_id to policy data, 79,882,364
alter table public.allpolicy add column llj_id integer;
-- updating the llj_id based on jurisdiction_id, gis_lati, gis_longi, 77,483,291
update public.allpolicy a
set llj_id = (
 select lj.llj_id 
 from fima.lljpolicy lj, public.llgridpolicy g
 where a.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi limit 1)
where exists(
 select lj.llj_id 
 from fima.lljpolicy lj, public.llgridpolicy g
 where a.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi);

-- updating the rest llj_id based on jurisdiction_id, select a random , 2,393,782
update public.allpolicy a 
set llj_id = (
 select lj.llj_id 
 from fima.lljpolicy lj
 where a.jurisdiction_id = lj.jurisdiction_id 
 order by random() limit 1)
where llj_id is null and
exists(
 select lj.llj_id 
 from fima.lljpolicy lj
 where a.jurisdiction_id = lj.jurisdiction_id);

-- updating the rest llj_id based on gis_lati, gis_longi, select a random of the already assigned, 4,275
update public.allpolicy a
set llj_id = (
 select aa.llj_id 
 from public.allpolicy aa
 where a.gis_lati = aa.gis_lati and
 a.gis_longi = aa.gis_longi and
 aa.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select aa.llj_id 
 from public.allpolicy aa
 where a.gis_lati = aa.gis_lati and
 a.gis_longi = aa.gis_longi and
 aa.llj_id is not null);

-- updating the rest llj_id based on re_community, select a random of the already assigned, 805
update public.allpolicy a
set llj_id = (
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_community = aa.re_community and
 aa.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_community = aa.re_community and
 aa.llj_id is not null);
 
 -- updating the rest llj_id based on re_state, select a random of the already assigned, 211
update public.allpolicy a
set llj_id = (
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_state = aa.re_state and
 aa.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_state = aa.re_state and
 aa.llj_id is not null);
 
---------------------------------------------------------------------------------------------------------------------------------------- 
-- adding llj_id to claims data, 1,625,472
alter table public.paidclaims add column llj_id integer;
-- updating the llj_id based on jurisdiction_id, gis_lati, gis_longi, 1,508,065
update public.paidclaims p
set llj_id = (
 select lj.llj_id 
 from fima.llj lj, public.llgrid g
 where p.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 p.gis_lati = g.gis_lati and
 p.gis_longi = g.gis_longi limit 1)
where exists(
 select lj.llj_id 
 from fima.llj lj, public.llgrid g
 where p.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 p.gis_lati = g.gis_lati and
 p.gis_longi = g.gis_longi);

-- updating the rest llj_id based on jurisdiction_id, select a random, 115,685
update public.paidclaims p
set llj_id = (
 select lj.llj_id 
 from fima.llj lj
 where p.jurisdiction_id = lj.jurisdiction_id 
 order by random() limit 1)
where llj_id is null and
exists(
 select lj.llj_id 
 from fima.llj lj
 where p.jurisdiction_id = lj.jurisdiction_id);

-- updating the rest llj_id based on gis_lati, gis_longi, select a random of the already assigned, 1,554
update public.paidclaims p
set llj_id = (
 select pp.llj_id 
 from public.paidclaims pp
 where p.gis_lati = pp.gis_lati and
 p.gis_longi = pp.gis_longi and
 pp.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select pp.llj_id 
 from public.paidclaims pp
 where p.gis_lati = pp.gis_lati and
 p.gis_longi = pp.gis_longi and
 pp.llj_id is not null);
 
-- updating the rest llj_id based on re_community, select a random of the already assigned, 91
update public.paidclaims p
set llj_id = (
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_community = pp.re_community and
 pp.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_community = pp.re_community and
 pp.llj_id is not null);
 
 -- updating the rest llj_id based on re_state, select a random of the already assigned, 77
update public.paidclaims p
set llj_id = (
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_state = pp.re_state and
 pp.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_state = pp.re_state and
 pp.llj_id is not null);
 









select p.effdate, corr(p.count, j.income) 
from summary.policy_monthlyeff_2015_llj p, fima.lljpolicy_income j 
where p.llj_id = j.llj_id 
group by 1 order by 1;







https://github.com/ucd-cws/nfip-db/blob/master/sql/policy_summary.sql

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
add primary key (llj_id,end_eff_dt, year,month,day);

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
