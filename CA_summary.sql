set search_path=ca,summary,fima,public,us;

-- Claims data
-- 1
drop table ca.ca_claims_monthly_summary_j;
create table ca.ca_claims_monthly_summary_j as
select
j.jurisdiction_id,
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
join fima.jurisdictions j using (jurisdiction_id)
where j.j_statefp10 = '06'
group by 1,2,3
order by 1,2,3;

alter table ca.ca_claims_monthly_summary_j
add primary key (jurisdiction_id,year,month);

--1.1
drop table ca.ca_claims_monthly_summary_2015_j;
create table ca.ca_claims_monthly_summary_2015_j as
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
 from ca.ca_claims_monthly_summary_j)
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

alter table ca.ca_claims_monthly_summary_2015_j add primary key (jurisdiction_id,year,month);

-- qgis layer for accumulative monthly claims by community level, in 2015 dollar value
drop table ca.ca_claims_accum_monthly_2015_j;
create table ca.ca_claims_accum_monthly_2015_j
as select
s.jurisdiction_id,
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
from ca.ca_claims_monthly_summary_2015_j s
join fima.jurisdictions j using (jurisdiction_id);

-- qgis layer for accumulative monthly claims per capita by community level, in 2015 dollar value
drop table ca.ca_claims_accum_monthly_2015_j_pop10;
create table ca.ca_claims_accum_monthly_2015_j_pop10
as select
s.jurisdiction_id,
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
from ca.ca_claims_accum_monthly_2015_j s
join fima.jurisdictions j using (jurisdiction_id)
order by year, month;


-- 2
drop table ca.ca_claims_monthly_summary_llj;
create table ca.ca_claims_monthly_summary_llj as
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
join fima.jurisdictions j using (jurisdiction_id)
join fima.llj lj using (jurisdiction_id,llgrid_id)
where re_state = 'CA'
group by 1,2,3
order by 1,2,3;

alter table ca.ca_claims_monthly_summary_llj add primary key (llj_id,year,month);

-- 2.1
drop table ca.ca_claims_monthly_summary_2015_llj;
create table ca.ca_claims_monthly_summary_2015_llj as
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
 from ca.ca_claims_monthly_summary_llj)
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

alter table ca.ca_claims_monthly_summary_2015_llj add primary key (llj_id,year,month);


-- qgis layer for accumulative monthly claims by joined 0.1lat/long-community level, in 2015 dollar value
drop table ca.ca_claims_accum_monthly_2015_llj;
create table ca.ca_claims_accum_monthly_2015_llj
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
from ca.ca_claims_monthly_summary_2015_llj
join fima.llj lj using (llj_id);


-- qgis layer for accumulative monthly claims per capita by joined 0.1lat/long-community level, in 2015 dollar value
drop table ca.ca_claims_accum_monthly_2015_llj_pop10;
create table ca.ca_claims_accum_monthly_2015_llj_pop10
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
from ca.ca_claims_accum_monthly_2015_llj s
join fima.llj_population ljp using (llj_id)
order by year, month;

-- cd Downloads/CA/CA_accumulative_monthly_#claims
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o CA_Accumulative_Monthly_#claims.mp4

-- cd Downloads/CA/CA_accumulative_monthly_payclaims
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o CA_Accumulative_Monthly_payclaims.mp4

-- cd Downloads/CA/CA_accumulative_monthly_#claims_capita
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o CA_Accumulative_Monthly_#claims_capita.mp4



-- 3. Coastal Flood zone
alter table ca.ca_claims_monthly_summary_2015_j add column flood_zone character varying(3);

update ca.ca_claims_monthly_summary_2015_j v
set flood_zone = 'A'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('A')
 group by 1);

update ca.ca_claims_monthly_summary_2015_j v
set flood_zone = 'B'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('B')
 group by 1);
 
update ca.ca_claims_monthly_summary_2015_j v
set flood_zone = 'C'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('C','X')
 group by 1);

update ca.ca_claims_monthly_summary_2015_j v
set flood_zone = 'V'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('V')
 group by 1);
 
update ca.ca_claims_monthly_summary_2015_j v
set flood_zone = 'D'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('D')
 group by 1);
 
-- Policy Data
-- 4.
drop table ca.ca_policy_monthly_summary_j;
create table ca.ca_policy_monthly_summary_j as
select
j.jurisdiction_id,
extract(year from end_eff_dt) as year,
extract(month from end_eff_dt) as month,
sum(condo_unit) as condo_count,
sum(t_premium) as t_premium,
sum(t_cov_bldg) as t_cov_bldg,
sum(t_cov_cont) as t_cov_cont
from public.allpolicy a
join fima.jurisdictions j using (jurisdiction_id)
where j.j_statefp10 = '06'
group by 1,2,3
order by 1,2,3;


alter table ca.ca_policy_monthly_summary_j
add primary key (jurisdiction_id,year,month);

--4.1
drop table ca.ca_policy_monthly_summary_2015_j;
create table ca.ca_policy_monthly_summary_2015_j as
with s as (
 select
 jurisdiction_id,
 year,
 month,
 condo_count,
 t_premium,
 t_cov_bldg,
 t_cov_cont
 from ca.ca_policy_monthly_summary_j)
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

alter table ca.ca_policy_monthly_summary_2015_j add primary key (jurisdiction_id,year,month);

-- 5. Coastal Flood zone
alter table ca.ca_policy_monthly_summary_2015_j add column flood_zone character varying(3);
 
update ca.ca_policy_monthly_summary_2015_j v
set flood_zone = 'A'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('A')
 group by 1);

update ca.ca_policy_monthly_summary_2015_j v
set flood_zone = 'B'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('B')
 group by 1);
 
update ca.ca_policy_monthly_summary_2015_j v
set flood_zone = 'C'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('C','X')
 group by 1);

update ca.ca_policy_monthly_summary_2015_j v
set flood_zone = 'V'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('V')
 group by 1);
 
update ca.ca_policy_monthly_summary_2015_j v
set flood_zone = 'D'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from public.paidclaims pc
 join fima.jurisdictions j using (jurisdiction_id)
 where j.j_statefp10 = '06' AND
 substr(pc.flood_zone, 1, 1) IN ('D')
 group by 1); 
 
-- Data Summary
select flood_zone, sum(count) as count, sum(pay) 
from ca.ca_claims_monthly_summary_2015_j c
group by 1
order by 1;

select flood_zone, sum(condo_count) as count, sum(t_premium) 
from ca.ca_policy_monthly_summary_2015_j p
where p.year>=1994 and p.year<= 2014
group by 1
order by 1;

select flood_zone, sum(count) as count, sum(pay) 
from ca.ca_claims_monthly_summary_2015_j c
where c.year>=1994 and c.year<= 2014
group by 1
order by 1;

select state, ratio
from policy_premium_claim_pay_state
where state = 'CA';
