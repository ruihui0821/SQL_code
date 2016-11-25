-- Policy Data
-- 1. monthly new policy summary
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

--1.1 monthly new policy in 2015 dollar value
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

-- 2. Sacramento Valley, San Joaquin Valley and the rest of california
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
 
-- 2. annual policy summary
drop table ca.ca_policy_yearly_summary_j;
create table ca.ca_policy_yearly_summary_j as
select
jurisdiction_id,
extract(year from end_eff_dt) as year,
sum(condo_unit) as condo_count,
sum(t_premium) as t_premium,
sum(t_cov_bldg) as t_cov_bldg,
sum(t_cov_cont) as t_cov_cont
from ca.caallpolicy
group by 1,2
order by 1,2;

alter table ca.ca_policy_yearly_summary_j
add primary key (jurisdiction_id,year);

--2.1 annual policy in 2015 dollar value
drop table ca.ca_policy_yearly_summary_2015_j;
create table ca.ca_policy_yearly_summary_2015_j as
with s as (
 select
 jurisdiction_id,
 year,
 condo_count,
 t_premium,
 t_cov_bldg,
 t_cov_cont
 from ca.ca_policy_yearly_summary_j)
select
s.jurisdiction_id,
year,
condo_count,
t_premium*rate as t_premium,
t_cov_bldg*rate as t_cov_bldg,
t_cov_cont*rate as t_cov_cont,
to_year as dollars_in
from s join inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table ca.ca_policy_yearly_summary_2015_j add primary key (jurisdiction_id,year);

-- 4. Sacramento Valley, San Joaquin Valley and the rest of california
alter table ca.ca_policy_yearly_summary_2015_j add column valley character varying(6);

update ca.ca_policy_yearly_summary_2015_j v
set valley = 'SAV'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from ca.ca_policy_yearly_summary_2015_j
 join fima.jurisdictions j using (jurisdiction_id)
 where substr(j.j_cid,1,6) IN ( '060017','060019','060020','060022','060023','060024','060057','060059','060239','060240','060241','060242','060243','060262','060263','060264','060265','060266','060358','060359','060360','060394','060395','060396','060398','060400','060423','060424','060425','060426','060427','060428','060437','060460','060650','060721','060728','060746','060748','060758','060765','060767','060772','065053','065064')
 group by 1);

update ca.ca_policy_yearly_summary_2015_j v
set valley = 'SJV'
where v.jurisdiction_id in (
 select j.jurisdiction_id
 from ca.ca_policy_yearly_summary_2015_j
 join fima.jurisdictions j using (jurisdiction_id)
 where substr(j.j_cid,1,6) IN ('060044','060045','060046','060047','060048','060049','060050','060051','060052','060053','060054','060055','060075','060076','060077','060078','060079','060080','060081','060082','060084','060085','060086','060088','060089','060170','060172','060188','060189','060191','060299','060300','060302','060303','060384','060385','060387','060388','060389','060390','060391','060392','060393','060403','060404','060405','060406','060407','060409','060440','060443','060450','060454','060457','060644','060663','060706','060738','060747','065029','065063','065065','065066','065071','065073')
 group by 1);
 

select sum(t_premium) 
from ca.ca_policy_yearly_summary_2015_j p
where p.year>=1994 and p.year<= 2014 and valley = 'SAV'
group by year
order by year;


-- Sacramento Valley Communities
substr(community,1,6) IN ( '060017','060019','060020','060022','060023','060024','060057','060059','060239','060240','060241','060242','060243','060262','060263','060264','060265','060266','060358','060359','060360','060394','060395','060396','060398','060400','060423','060424','060425','060426','060427','060428','060437','060460','060650','060721','060728','060746','060748','060758','060765','060767','060772','065053','065064')

-- San Joaquin Valley Communities
substr(community,1,6) IN ('060044','060045','060046','060047','060048','060049','060050','060051','060052','060053','060054','060055','060075','060076','060077','060078','060079','060080','060081','060082','060084','060085','060086','060088','060089','060170','060172','060188','060189','060191','060299','060300','060302','060303','060384','060385','060387','060388','060389','060390','060391','060392','060393','060403','060404','060405','060406','060407','060409','060440','060443','060450','060454','060457','060644','060663','060706','060738','060747','065029','065063','065065','065066','065071','065073') 
