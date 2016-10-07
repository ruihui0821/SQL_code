set search_path=summary,fima,public,us;

--* Correcting jurisdiction_id (not llj_id) in claims_summary 1, 1.1

-- * Correcting re_state update in Data_Correction

UPDATE public.paidclaims pc
SET re_state = (
  SELECT sfc.fipsalphacode
  FROM fima.statefipscodes sfc
	JOIN fima.jurisdictions j ON (sfc.fipsnumbercode = j.j_statefp10)
	WHERE pc.re_community = j.j_cid LIMIT 1)
 WHERE EXISTS(
  SELECT sfc.fipsalphacode
  FROM fima.statefipscodes sfc
	JOIN fima.jurisdictions j ON (sfc.fipsnumbercode = j.j_statefp10)
	WHERE pc.re_community = j.j_cid) 
 
-- 1
drop table summary.matthew_claims_monthly_summary_j;
create table summary.matthew_claims_monthly_summary_j as
select
jurisdiction_id,
extract(year from dt_of_loss) as year,
extract(month from dt_of_loss) as month,
count(*),
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(t_dmg_bldg+t_dmg_cont) as t_dmg,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont,
sum(pay_bldg+pay_cont) as pay,
sum(pay_icc) as pay_icc,
avg(waterdepth)::decimal(6,2) as waterdepth
from public.paidclaims pc
inner join fima.jurisdictions j on (re_community=j.j_cid)
where j.j_statefp10 in('12','13','37','45')
group by 1,2,3
order by 1,2,3;
-- 'Florida','Georgia','North Carolina', 'South Carolina'

alter table summary.matthew_claims_monthly_summary_j
add primary key (jurisdiction_id,year,month);

--1.1
drop table summary.matthew_claims_monthly_summary_2015_j;
create table summary.matthew_claims_monthly_summary_2015_j as
with s as (
 select
 jurisdiction_id,
 year,
 month,
 count,
 t_dmg_bldg,
 t_dmg_cont,
 t_dmg,
 pay_bldg,
 pay_cont,
 pay,
 pay_icc
 from summary.matthew_claims_monthly_summary_j
 group by jurisdiction_id,year,month)
select
s.jurisdiction_id,
year,
month,
count,
t_dmg_bldg*rate as t_dmg_bldg,
t_dmg_cont*rate as t_dmg_cont,
t_dmg*rate as t_dmg,
pay_bldg*rate as pay_bldg,
pay_cont*rate as pay_cont,
pay*rate as pay,
pay_icc*rate as pay_icc,
to_year as dollars_in
from s join inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table summary.matthew_claims_monthly_summary_2015_j add primary key (jurisdiction_id,year,month);

-- qgis layer for accumulative monthly claims by community level, in 2015 dollar value
drop table us.matthew_claims_accum_monthly_2015_j;
create table us.matthew_claims_accum_monthly_2015_j
as select
jurisdiction_id,
year,
month,
sum(count) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_count,
sum(pay_bldg) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_pay_bldg,
sum(pay_cont) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_pay_cont,
sum(pay) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_pay,
sum(t_dmg_bldg) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_t_dmg_bldg,
sum(t_dmg_cont) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_t_dmg_cont,
sum(t_dmg) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_t_dmg,
extract(epoch from (year||'-'||CAST(month AS VARCHAR(2))||'-01')::date) as epoch_start,
extract(epoch from ((year||'-'||CAST(month AS VARCHAR(2))||'-01')::date + interval '1 month' - interval '1 day') ) as epoch_end,
extract(epoch from '2015-03-31'::date) as accu_epoch_end,
j.boundary
from summary.matthew_claims_monthly_summary_2015_j
inner join fima.jurisdictions j using (jurisdiction_id);

-- qgis layer for accumulative monthly claims per capita by community level, in 2015 dollar value
drop table us.matthew_claims_accum_monthly_2015_j_pop10;
create table us.matthew_claims_accum_monthly_2015_j_pop10
as select
jurisdiction_id,
year,
month,
j.j_pop10 as population,
j.shape_area as area,
accu_count/j.j_pop10 as accu_count_capita,
accu_pay/j.j_pop10 as accu_pay_capita,
epoch_start,
accu_epoch_end,
j.boundary
from us.matthew_claims_accum_monthly_2015_j
inner join fima.jurisdictions j using (jurisdiction_id);


-- 2
drop table summary.matthew_claims_monthly_summary_llj;
create table summary.matthew_claims_monthly_summary_llj as
select
llj_id,
extract(year from dt_of_loss) as year,
extract(month from dt_of_loss) as month,
count(*),
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(t_dmg_bldg+t_dmg_cont) as t_dmg,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont,
sum(pay_bldg+pay_cont) as pay,
sum(pay_icc) as pay_icc,
avg(waterdepth)::decimal(6,2) as waterdepth
from public.paidclaims pc
join llgrid g using (gis_longi,gis_lati)
join fima.jurisdictions j on (re_community=j.j_cid)
join fima.llj lj using (jurisdiction_id,llgrid_id)
where re_state in ('FL','GA','SC','NC')
group by 1,2,3
order by 1,2,3;

alter table summary.matthew_claims_monthly_summary_llj add primary key (llj_id,year,month);

-- 2.1
drop table summary.matthew_claims_monthly_summary_2015_llj;
create table summary.matthew_claims_monthly_summary_2015_llj as
with s as (
 select
 llj_id,
 year,
 month,
 count,
 t_dmg_bldg,
 t_dmg_cont,
 t_dmg,
 pay_bldg,
 pay_cont,
 pay,
 pay_icc
 from summary.matthew_claims_monthly_summary_llj
 group by llj_id,year,month)
select
s.llj_id,
year,
month,
count,
t_dmg_bldg*rate as t_dmg_bldg,
t_dmg_cont*rate as t_dmg_cont,
t_dmg*rate as t_dmg,
pay_bldg*rate as pay_bldg,
pay_cont*rate as pay_cont,
pay*rate as pay,
pay_icc*rate as pay_icc,
to_year as dollars_in
from s join inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table summary.matthew_claims_monthly_summary_2015_llj add primary key (llj_id,year,month);


-- qgis layer for accumulative monthly claims by joined 0.1lat/long-community level, in 2015 dollar value
drop table us.matthew_claims_accum_monthly_2015_llj;
create table us.matthew_claims_accum_monthly_2015_llj
as select
llj_id,
year,
month,
sum(count) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_count,
sum(pay_bldg) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_pay_bldg,
sum(pay_cont) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_pay_cont,
sum(pay) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_pay,
sum(t_dmg_bldg) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_t_dmg_bldg,
sum(t_dmg_cont) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_t_dmg_cont,
sum(t_dmg) OVER(PARTITION BY jurisdiction_id ORDER BY year, month) AS accu_t_dmg,
extract(epoch from (year||'-'||CAST(month AS VARCHAR(2))||'-01')::date) as epoch_start,
extract(epoch from ((year||'-'||CAST(month AS VARCHAR(2))||'-01')::date + interval '1 month' - interval '1 day') ) as epoch_end,
extract(epoch from '2015-03-31'::date) as accu_epoch_end,
lj.boundary
from summary.matthew_claims_monthly_summary_2015_llj
join fima.llj lj using (llj_id);


-- qgis layer for accumulative monthly claims per capita by joined 0.1lat/long-community level, in 2015 dollar value
drop table us.matthew_claims_accum_monthly_2015_llj_pop10;
create table us.matthew_claims_accum_monthly_2015_llj_pop10
as select
llj_id,
year,
month,
ljp.pop10 as population,
accu_count/ljp.pop10 as accu_count_capita,
accu_pay_bldg/ljp.pop10 as accu_pay_bldg_capita,
accu_pay_cont/ljp.pop10 as accu_pay_cont_capita,
accu_pay/ljp.pop10 as accu_pay_capita,
accu_t_dmg_bldg/ljp.pop10 as accu_t_dmg_bldg_capita,
accu_t_dmg_cont/ljp.pop10 as accu_t_dmg_cont_capita,
accu_t_dmg/ljp.pop10 as accu_t_dmg_capita,
epoch_start,
epoch_end,
accu_epoch_end,
lj.boundary
from us.matthew_claims_accum_monthly_2015_llj
join fima.llj_population ljp using (llj_id);
