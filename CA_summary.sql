set search_path=ca,summary,fima,public,us;

drop table ca.capaidclaims;
create table ca.capaidclaims as
select pc.*
from public.paidclaims pc
join fima.jurisdictions j using (jurisdiction_id)
where j.j_statefp10 = '06' or pc.re_state = 'CA';

alter table ca.capaidclaims
add primary key (gid,pcid);

drop table ca.caallpolicy;
create table ca.caallpolicy as
select ap.*
from public.allpolicy ap
join fima.jurisdictions j using (jurisdiction_id)
where j.j_statefp10 = '06' or ap.re_state = 'CA';

alter table ca.caallpolicy
add primary key (apid);

-- Claims data
-- 1
drop table ca.ca_claims_monthly_summary_j;
create table ca.ca_claims_monthly_summary_j as
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
from ca.capaidclaims
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

-- 1.2 annual summary, 
-- Not Making yet
drop table ca.ca_claims_yearly_2015_j;
create table ca.ca_claims_yearly_2015_j as
with s as (
 select
 jurisdiction_id,
 year,
 sum(count) as count,
 sum(t_dmg_bldg) as t_dmg_bldg,
 sum(t_dmg_cont) as t_dmg_cont,
 sum(t_dmg) as t_dmg,
 sum(pay_bldg) as pay_bldg,
 sum(pay_cont) as pay_cont,
 sum(pay) as pay,
 sum(pay_icc) as pay_icc
 from ca.ca_claims_monthly_summary_j
 group by 1,2
)
select
s.jurisdiction_id,
year,
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

alter table ca.ca_claims_yearly_2015_j add primary key (jurisdiction_id,year);

-- qgis layer for accumulative monthly claims by community level, in 2015 dollar value
-- not making yet
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
-- not making yet
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
from ca.capaidclaims
join llgrid g using (gis_longi,gis_lati)
join fima.jurisdictions j using (jurisdiction_id)
join fima.llj lj using (jurisdiction_id,llgrid_id)
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

-- 2.2 annual summary
drop table ca.ca_claims_yearly_2015_llj;
create table ca.ca_claims_yearly_2015_llj as
with s as (
 select
 llj_id,
 year,
 sum(count) as count,
 sum(t_dmg_bldg) as t_dmg_bldg,
 sum(t_dmg_cont) as t_dmg_cont,
 sum(t_dmg) as t_dmg,
 sum(pay_bldg) as pay_bldg,
 sum(pay_cont) as pay_cont,
 sum(pay) as pay,
 sum(pay_icc) as pay_icc
 from ca.ca_claims_monthly_summary_llj
 group by 1,2
)
select
s.llj_id,
year,
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

alter table ca.ca_claims_yearly_2015_llj add primary key (llj_id,year);

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
-- not making yet
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

-- qgis layer for accumulative monthly claims by joined 0.1lat/long-community level, in 2015 dollar value
drop table ca.ca_claims_yearly_llj;
create table ca.ca_claims_yearly_llj
as select
llj_id,
year,
count,
pay_bldg,
pay_cont,
pay,
t_dmg_bldg,
t_dmg_cont,
t_dmg,
extract(epoch from (year||'-01-01')::date) as epoch_start ,
extract(epoch from (year||'-12-31')::date) as epoch_end,
lj.boundary
from ca.ca_claims_yearly_2015_llj s
join fima.llj lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
order by 1, 2;

drop table ca.ca_claims_llj;
create table ca.ca_claims_llj
as select
llj_id,
lj.boundary,
sum(count) as count,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont,
sum(pay) as pay,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(t_dmg) as t_dmg
from ca.ca_claims_yearly_2015_llj s
join fima.llj lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
group by 1, 2;

-- cd Downloads/CA/CA_accumulative_monthly_#claims
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o CA_Accumulative_Monthly_#claims.mp4

-- cd Downloads/CA/CA_accumulative_monthly_payclaims
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o CA_Accumulative_Monthly_payclaims.mp4

-- cd Downloads/CA/CA_accumulative_monthly_#claims_capita
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o CA_Accumulative_Monthly_#claims_capita.mp4


-- 3 Sacramento Valley, San Joaquin Valley and the rest of california
alter table ca.ca_claims_monthly_summary_2015_j add column valley character varying(6);

update ca.ca_claims_monthly_summary_2015_j v
set valley = 'SAV'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from ca.ca_claims_monthly_summary_2015_j
 join fima.jurisdictions j using (jurisdiction_id)
 where substr(j.j_cid,1,6) IN ( '060017','060019','060020','060022','060023','060024','060057','060059','060239','060240','060241','060242','060243','060262','060263','060264','060265','060266','060358','060359','060360','060394','060395','060396','060398','060400','060423','060424','060425','060426','060427','060428','060437','060460','060650','060721','060728','060746','060748','060758','060765','060767','060772','065053','065064')
 group by 1);

update ca.ca_claims_monthly_summary_2015_j v
set valley = 'SJV'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from ca.ca_claims_monthly_summary_2015_j
 join fima.jurisdictions j using (jurisdiction_id)
 where substr(j.j_cid,1,6) IN ('060044','060045','060046','060047','060048','060049','060050','060051','060052','060053','060054','060055','060075','060076','060077','060078','060079','060080','060081','060082','060084','060085','060086','060088','060089','060170','060172','060188','060189','060191','060299','060300','060302','060303','060384','060385','060387','060388','060389','060390','060391','060392','060393','060403','060404','060405','060406','060407','060409','060440','060443','060450','060454','060457','060644','060663','060706','060738','060747','065029','065063','065065','065066','065071','065073')
 group by 1);
 
-- Policy Data
-- 4.
drop table ca.ca_policy_monthly_summary_j;
create table ca.ca_policy_monthly_summary_j as
select
jurisdiction_id,
extract(year from end_eff_dt) as year,
extract(month from end_eff_dt) as month,
sum(condo_unit) as condo_count,
sum(t_premium) as t_premium,
sum(t_cov_bldg) as t_cov_bldg,
sum(t_cov_cont) as t_cov_cont
from ca.caallpolicy
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

-- 5. Sacramento Valley, San Joaquin Valley and the rest of california
alter table ca.ca_policy_monthly_summary_2015_j add column valley character varying(6);

update ca.ca_policy_monthly_summary_2015_j v
set valley = 'SAV'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from ca.ca_policy_monthly_summary_2015_j
 join fima.jurisdictions j using (jurisdiction_id)
 where substr(j.j_cid,1,6) IN ( '060017','060019','060020','060022','060023','060024','060057','060059','060239','060240','060241','060242','060243','060262','060263','060264','060265','060266','060358','060359','060360','060394','060395','060396','060398','060400','060423','060424','060425','060426','060427','060428','060437','060460','060650','060721','060728','060746','060748','060758','060765','060767','060772','065053','065064')
 group by 1);

update ca.ca_policy_monthly_summary_2015_j v
set valley = 'SJV'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from ca.ca_policy_monthly_summary_2015_j
 join fima.jurisdictions j using (jurisdiction_id)
 where substr(j.j_cid,1,6) IN ('060044','060045','060046','060047','060048','060049','060050','060051','060052','060053','060054','060055','060075','060076','060077','060078','060079','060080','060081','060082','060084','060085','060086','060088','060089','060170','060172','060188','060189','060191','060299','060300','060302','060303','060384','060385','060387','060388','060389','060390','060391','060392','060393','060403','060404','060405','060406','060407','060409','060440','060443','060450','060454','060457','060644','060663','060706','060738','060747','065029','065063','065065','065066','065071','065073')
 group by 1);
 
-- Data Summary by flood zone
alter table ca.capaidclaims add column fzone character varying(3);

update ca.capaidclaims
set fzone = 'A'
where substr(flood_zone,1,1) IN ('A');

update ca.capaidclaims
set fzone = 'B'
where substr(flood_zone,1,1) IN ('B');

update ca.capaidclaims
set fzone = 'C'
where substr(flood_zone,1,1) IN ('C','X');

update ca.capaidclaims
set fzone = 'V'
where substr(flood_zone,1,1) IN ('V');

update ca.capaidclaims
set fzone = 'D'
where substr(flood_zone,1,1) IN ('D');

with s as (
 select extract(year from dt_of_loss) as year, sum(pay_cont) as pay
 from ca.capaidclaims c
 group by 1
 order by 1)
select pay from s order by year;

select sum(t_premium) 
from ca.caallpolicy p
where end_eff_dt >= '1994-01-01' and end_eff_dt <= '2014-12-31';

select count(*), sum(pay_bldg+pay_cont) 
from ca.capaidclaims c
where dt_of_loss >= '1994-01-01' and dt_of_loss <= '2014-12-31'
and substr(flood_zone,1,1) IN ('A');

-- Data summary by Valley
select sum(count) 
from ca.ca_claims_monthly_summary_2015_j c
group by year
order by year;

select sum(t_premium) 
from ca.ca_policy_monthly_summary_2015_j p
where p.year>=1994 and p.year<= 2014 and valley = 'SAV'
group by year
order by year;

select flood_zone, sum(count) as count, sum(pay) 
from ca.ca_claims_monthly_summary_2015_j c
where c.year>=1994 and c.year<= 2014
group by 1
order by 1;

-- Sacramento Valley Communities
substr(community,1,6) IN ( '060017','060019','060020','060022','060023','060024','060057','060059','060239','060240','060241','060242','060243','060262','060263','060264','060265','060266','060358','060359','060360','060394','060395','060396','060398','060400','060423','060424','060425','060426','060427','060428','060437','060460','060650','060721','060728','060746','060748','060758','060765','060767','060772','065053','065064')

-- San Joaquin Valley Communities
substr(community,1,6) IN ('060044','060045','060046','060047','060048','060049','060050','060051','060052','060053','060054','060055','060075','060076','060077','060078','060079','060080','060081','060082','060084','060085','060086','060088','060089','060170','060172','060188','060189','060191','060299','060300','060302','060303','060384','060385','060387','060388','060389','060390','060391','060392','060393','060403','060404','060405','060406','060407','060409','060440','060443','060450','060454','060457','060644','060663','060706','060738','060747','065029','065063','065065','065066','065071','065073') 
