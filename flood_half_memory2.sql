with a as (
  select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  group by 1, 2
  order by 1, 2),
b as (
  select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  where t_premium >10000 and t_premium<15000
  group by 1, 2
  order by 1, 2),
c as (
select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  where post_firm = 'N'
  group by 1, 2
  order by 1, 2),
d as (
select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  where t_premium >10000 and t_premium<15000
  and post_firm = 'N'
  group by 1, 2
  order by 1, 2)
select
a.year,
sum(a.policy) as t_policy,
sum(b.policy) as policy,
sum(b.policy)/sum(a.policy) as ratio,
sum(c.policy) as t_policy_prefirm,
sum(d.policy) as policy_prefirm,
sum(d.policy)/sum(c.policy) as ratio_prefirm
from a join b using (year) join c using (year) join d using (year)
group by 1 order by 1;

----------------------------------------------------------------------------------------------------------------------------------------
alter table public.paidclaims add column county character varying(64);
update public.paidclaims p 
set county = (
  select n.county_name 
  from fima.nation n 
  where n.cid = p.re_community and n.county_name is not null) 
where exists (
  select n.county_name 
  from fima.nation n 
  where n.cid = p.re_community and n.county_name is not null) 
and re_state in ('CA', 'LA', 'IL', 'NY'); 

----1.1 Claim summary
drop table summary.fmhl_claims_summary_2015;
create table summary.fmhl_claims_summary_2015 as
with s as (
  select
  f.state,
  f.county,
  f.days,
  f.households,
  p.fzone,
  p.post_firm,
  extract(year from dt_of_loss) as year,
  count(p.*),
  sum(p.t_dmg_bldg) as t_dmg_bldg,
  sum(p.t_dmg_cont) as t_dmg_cont,
  sum(p.pay_bldg) as pay_bldg,
  sum(p.pay_cont) as pay_cont,
  sum(t_prop_val) as t_prop_val
  from summary.fmhl f 
  left join public.paidclaims p on (f.state = p.re_state) AND (f.county = p.county)
  where p.re_state in ('CA', 'LA', 'NY', 'IL')
  group by 1, 2, 3, 4, 5, 6, 7
  order by 1, 2, 3, 4, 5, 6, 7
)
select
s.state,
s.county,
s.days,
s.households,
s.fzone,
s.post_firm,
s.year,
s.count,
(s.pay_bldg + s.pay_cont)*rate as pay,
(s.t_dmg_bldg + s.t_dmg_cont)*rate as t_dmg,
s.t_prop_val*rate as t_prop_val,
s.t_dmg_bldg*rate as t_dmg_bldg,
s.t_dmg_cont*rate as t_dmg_cont,
s.pay_bldg*rate as pay_bldg,
s.pay_cont*rate as pay_cont,
i.to_year as dollars_in
from s join public.inflation i on (i.from_year=s.year) 
where i.to_year=2015;

update summary.fmhl_claims_summary_2015 set t_prop_val = 0.1 where t_prop_val=0;

----1.2 Claim summary for the flood disaster
drop table summary.fmhl_claims_summary_disaster_2015;
create table summary.fmhl_claims_summary_disaster_2015 as
with s as (
  select
  f.state,
  f.county,
  f.days,
  f.households,
  p.fzone,
  p.post_firm,
  extract(year from dt_of_loss) as year,
  count(p.*),
  sum(p.t_dmg_bldg) as t_dmg_bldg,
  sum(p.t_dmg_cont) as t_dmg_cont,
  sum(p.pay_bldg) as pay_bldg,
  sum(p.pay_cont) as pay_cont,
  sum(t_prop_val) as t_prop_val
  from summary.fmhl f 
  left join public.paidclaims p on (f.state = p.re_state) AND (f.county = p.county)
  where p.re_state in ('CA', 'LA', 'NY', 'IL')
  and p.dt_of_loss >= disaster_date - interval '3 month'
  and p.dt_of_loss <= disaster_date + interval '9 month'
  group by 1, 2, 3, 4, 5, 6, 7
  order by 1, 2, 3, 4, 5, 6, 7
)
select
s.state,
s.county,
s.days,
s.households,
s.fzone,
s.post_firm,
s.year,
s.count,
(s.pay_bldg + s.pay_cont)*rate as pay,
(s.t_dmg_bldg + s.t_dmg_cont)*rate as t_dmg,
s.t_prop_val*rate as t_prop_val,
s.t_dmg_bldg*rate as t_dmg_bldg,
s.t_dmg_cont*rate as t_dmg_cont,
s.pay_bldg*rate as pay_bldg,
s.pay_cont*rate as pay_cont,
i.to_year as dollars_in
from s join public.inflation i on (i.from_year=s.year) 
where i.to_year=2015;

alter table summary.fmhl_claims_summary_disaster_2015 add primary key (state, county);

update summary.fmhl_claims_summary_disaster_2015 set t_prop_val = 0.1 where t_prop_val=0;

select count(*) from public.paidclaims 
where re_state = 'CA' and county = 'Imperial' 
and dt_of_loss >= ('1997-01-04'::date - interval '3 month') 
and dt_of_loss <= ('1997-01-04'::date + interval '9 month');


----2.1 Claim summary for the flood disaster
drop table summary.fmhl_claims_2015;
create table summary.fmhl_claims_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_2015
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_2015 add primary key (state, county);

----2.2 Claim summary for the flood disaster
drop table summary.fmhl_claims_disaster_2015;
create table summary.fmhl_claims_disaster_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_disaster_2015
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_disaster_2015 add primary key (state, county);

----3.1 Claim summary for flood zones, zone A.
drop table summary.fmhl_claims_fzonea_2015;
create table summary.fmhl_claims_fzonea_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_2015
where fzone = 'A'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_fzonea_2015 add primary key (state, county);

----3.2 Claim summary for flood zones, zone B.
drop table summary.fmhl_claims_fzoneb_2015;
create table summary.fmhl_claims_fzoneb_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_2015
where fzone = 'B'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_fzoneb_2015 add primary key (state, county);

----3.3 Claim summary for flood zones, zone C.
drop table summary.fmhl_claims_fzonec_2015;
create table summary.fmhl_claims_fzonec_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_2015
where fzone in ('C','D')
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_fzonec_2015 add primary key (state, county);

----3.4 Claim summary for flood zones, zone V.
drop table summary.fmhl_claims_fzonev_2015;
create table summary.fmhl_claims_fzonev_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_2015
where fzone ='V'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_fzonev_2015 add primary key (state, county);

----3.5 Claim summary for the flood disaster for flood zones, zone A.
drop table summary.fmhl_claims_disaster_fzonea_2015;
create table summary.fmhl_claims_disaster_fzonea_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_disaster_2015
where fzone = 'A'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_disaster_fzonea_2015 add primary key (state, county);

----3.6 Claim summary for the flood disaster for flood zones, zone B.
drop table summary.fmhl_claims_disaster_fzoneb_2015;
create table summary.fmhl_claims_disaster_fzoneb_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_disaster_2015
where fzone = 'B'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_disaster_fzoneb_2015 add primary key (state, county);

----3.7 Claim summary for the flood disaster for flood zones, zone C.
drop table summary.fmhl_claims_disaster_fzonec_2015;
create table summary.fmhl_claims_disaster_fzonec_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_disaster_2015
where fzone in ('C','D')
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_disaster_fzonec_2015 add primary key (state, county);

----3.8 Claim summary for the flood disaster for flood zones, zone V.
drop table summary.fmhl_claims_disaster_fzonev_2015;
create table summary.fmhl_claims_disaster_fzonev_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_disaster_2015
where fzone ='V'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_disaster_fzonev_2015 add primary key (state, county);

----4.1 Claim summary for post-firm structure.
drop table summary.fmhl_claims_postfirm_2015;
create table summary.fmhl_claims_postfirm_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_2015
where post_firm = 'Y'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_postfirm_2015 add primary key (state, county);

----4.2 Claim summary for pre-firm structure.
drop table summary.fmhl_claims_prefirm_2015;
create table summary.fmhl_claims_prefirm_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_2015
where post_firm = 'N'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_prefirm_2015 add primary key (state, county);

----4.3 Claim summary for flood disaster for post-firm structure.
drop table summary.fmhl_claims_disaster_postfirm_2015;
create table summary.fmhl_claims_disaster_postfirm_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_disaster_2015
where post_firm = 'Y'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_disaster_postfirm_2015 add primary key (state, county);

----4.4 Claim summary for flood disaster pre-firm structure.
drop table summary.fmhl_claims_disaster_prefirm_2015;
create table summary.fmhl_claims_disaster_prefirm_2015 as
select
state,
county,
days,
households,
sum(count) as count,
sum(pay) as pay,
sum(t_dmg) as t_dmg,
sum(t_prop_val) as t_prop_val,
sum(t_dmg)/sum(t_prop_val) as damage_ratio,
sum(t_dmg_bldg) as t_dmg_bldg,
sum(t_dmg_cont) as t_dmg_cont,
sum(pay_bldg) as pay_bldg,
sum(pay_cont) as pay_cont
from summary.fmhl_claims_summary_disaster_2015
where post_firm = 'N'
group by 1, 2, 3, 4
order by 1, 2;

alter table summary.fmhl_claims_disaster_prefirm_2015 add primary key (state, county);

