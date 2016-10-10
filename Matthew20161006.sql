set search_path=summary,fima,public,us;

-- Claims data
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
join fima.jurisdictions j on (re_community=j.j_cid)
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
 from summary.matthew_claims_monthly_summary_j)
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
join fima.jurisdictions j using (jurisdiction_id);

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
epoch_end,
accu_epoch_end,
s.boundary
from us.matthew_claims_accum_monthly_2015_j s
join fima.jurisdictions j using (jurisdiction_id)
order by year, month;


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
 from summary.matthew_claims_monthly_summary_llj)
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
s.boundary
from us.matthew_claims_accum_monthly_2015_llj s
join fima.llj_population ljp using (llj_id)
order by year, month;

-- cd Downloads/Matthew/Matthew_accumulative_monthly_#claims
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o Matthew_Accumulative_Monthly_#claims.mp4

-- cd Downloads/Matthew/Matthew_accumulative_monthly_payclaims
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o Matthew_Accumulative_Monthly_payclaims.mp4

-- cd Downloads/Matthew/Matthew_accumulative_monthly_#claims_capita
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o Matthew_Accumulative_Monthly_#claims_capita.mp4



-- 3. Coastal Flood zone
alter table summary.matthew_claims_monthly_summary_2015_j add column flood_zone character varying(3);

update summary.matthew_claims_monthly_summary_2015_j v
set flood_zone = 'V'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j on (pc.re_community=j.j_cid)
 where j.j_statefp10 in('12','13','37','45') AND
 substr(pc.flood_zone, 1, 1) IN ('V')
 group by 1);



-- Policy Data
-- 4.
drop table summary.matthew_policy_monthly_summary_j;
create table summary.matthew_policy_monthly_summary_j as
select
jurisdiction_id,
extract(year from end_eff_dt) as year,
extract(month from end_eff_dt) as month,
sum(condo_unit) as condo_count,
sum(t_premium) as t_premium,
sum(t_cov_bldg) as t_cov_bldg,
sum(t_cov_cont) as t_cov_cont
from public.allpolicy a
join fima.jurisdictions j on (re_community=j.j_cid)
where j.j_statefp10 in('12','13','37','45')
group by 1,2,3
order by 1,2,3;
-- 'Florida','Georgia','North Carolina', 'South Carolina'

alter table summary.matthew_policy_monthly_summary_j
add primary key (jurisdiction_id,year,month);

--4.1
drop table summary.matthew_policy_monthly_summary_2015_j;
create table summary.matthew_policy_monthly_summary_2015_j as
with s as (
 select
 jurisdiction_id,
 year,
 month,
 condo_count,
 t_premium,
 t_cov_bldg,
 t_cov_cont
 from summary.matthew_policy_monthly_summary_j)
select
s.jurisdiction_id,
year,
month,
condo_count,
t_premium*rate as t_premium,
t_cov_bldg*rate as t_cov_bldg,
t_cov_cont*rate as t_cov_cont,
to_year as dollars_in
from s join inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table summary.matthew_policy_monthly_summary_2015_j add primary key (jurisdiction_id,year,month);

-- 5. Coastal Flood zone
alter table summary.matthew_policy_monthly_summary_2015_j add column flood_zone character varying(3);

update summary.matthew_policy_monthly_summary_2015_j v
set flood_zone = 'V'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j on (pc.re_community=j.j_cid)
 where j.j_statefp10 in('12','13','37','45') AND
 substr(pc.flood_zone, 1, 1) IN ('V')
 group by 1);
 
 
 
-- Data Summary
-- State wide and coastal zone claims summary
select s.fipsalphacode, count(*), sum(pay) 
from summary.matthew_claims_monthly_summary_2015_j c
join fima.jurisdictions j using (jurisdiction_id)
join fima.statefipscodes s on (j.j_statefp10 = s.fipsnumbercode)
where c.flood_zone = 'V'
group by 1
order by 1;
-- State wide and coastal zone policy summary
select s.fipsalphacode, sum(t_premium) 
from summary.matthew_policy_monthly_summary_2015_j p
join fima.jurisdictions j using (jurisdiction_id)
join fima.statefipscodes s on (j.j_statefp10 = s.fipsnumbercode)
where p.year>=1994 and p.year<= 2014 
and p.flood_zone = 'V'
group by 1
order by 1;
-- 1994-2014 ratio
select s.fipsalphacode, count(*), sum(pay) 
from summary.matthew_claims_monthly_summary_2015_j c
join fima.jurisdictions j using (jurisdiction_id)
join fima.statefipscodes s on (j.j_statefp10 = s.fipsnumbercode)
where c.year>=1994 and c.year<= 2014 
and c.flood_zone = 'V'
group by 1
order by 1;

select state, ratio
from policy_premium_claim_pay_state
where state in ('FL','GA','SC','NC');

SELECT 
re_state, 
extract(year FROM dt_of_loss) AS year, 
count(*) 
FROM public.paidclaims pc 
	 JOIN fima.jurisdictions j ON (pc.re_community = j.j_cid)
	 JOIN fima.statefipscodes sfc ON (sfc.fipsnumbercode = j.j_statefp10)
WHERE pc.re_state!=sfc.fipsalphacode
GROUP BY 1,2
ORDER BY 1,2;

SELECT 
re_state, 
extract(year FROM end_eff_dt) AS year, 
count(*) 
FROM public.allpolicy ap 
	 JOIN fima.jurisdictions j ON (ap.re_community = j.j_cid)
	 JOIN fima.statefipscodes sfc ON (sfc.fipsnumbercode = j.j_statefp10)
WHERE ap.re_state!=sfc.fipsalphacode
GROUP BY 1,2
ORDER BY 1,2;
