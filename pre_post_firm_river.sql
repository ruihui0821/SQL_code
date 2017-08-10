-- 1.1 SUMMARY TABEL FOR PRE-FIRM CLAIMS in riverine flood A zone
drop table summary.prefirm_claim_state_jurisdiction_2015a;
create table summary.prefirm_claim_state_jurisdiction_2015a as
with s as (
  select
  extract(year from dt_of_loss) as year,
  re_state as state,
  re_community as community,
  jurisdiction_id,
  count(*),
  sum(pay_bldg+pay_cont) as pay,
  sum(t_dmg_bldg + t_dmg_cont) as t_dmg,
  sum(t_dmg_bldg) as t_dmg_bldg,
  sum(t_dmg_cont) as t_dmg_cont,
  sum(pay_bldg) as pay_bldg,
  sum(pay_cont) as pay_cont,
  sum(pay_icc) as pay_icc
  from public.paidclaims pc
  where post_firm = 'N'
  and fzone = 'A'
  group by 1,2,3,4
  order by 1,2,3,4)
select
s.year,
s.state,
s.community,
s.jurisdiction_id,
s.count,
s.pay*rate as pay,
s.t_dmg*rate as t_dmg,
s.t_dmg_bldg*rate as t_dmg_bldg,
s.t_dmg_cont*rate as t_dmg_cont,
s.pay_bldg*rate as pay_bldg,
s.pay_cont*rate as pay_cont,
s.pay_icc*rate as pay_icc,
to_year as dollars_in
from s join public.inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table summary.prefirm_claim_state_jurisdiction_2015a add primary key (year, state, community, jurisdiction_id);

-- 1.2 SUMMARY TABEL FOR POST-FIRM CLAIMS in riverine flood A zone
drop table summary.postfirm_claim_state_jurisdiction_2015a;
create table summary.postfirm_claim_state_jurisdiction_2015a as
with s as (
  select
  extract(year from dt_of_loss) as year,
  re_state as state,
  re_community as community,
  jurisdiction_id,
  count(*),
  sum(pay_bldg+pay_cont) as pay,
  sum(t_dmg_bldg + t_dmg_cont) as t_dmg,
  sum(t_dmg_bldg) as t_dmg_bldg,
  sum(t_dmg_cont) as t_dmg_cont,
  sum(pay_bldg) as pay_bldg,
  sum(pay_cont) as pay_cont,
  sum(pay_icc) as pay_icc
  from public.paidclaims pc
  where post_firm = 'Y'
  and fzone = 'A'
  group by 1,2,3,4
  order by 1,2,3,4)
select
s.year,
s.state,
s.community,
s.jurisdiction_id,
s.count,
s.pay*rate as pay,
s.t_dmg*rate as t_dmg,
s.t_dmg_bldg*rate as t_dmg_bldg,
s.t_dmg_cont*rate as t_dmg_cont,
s.pay_bldg*rate as pay_bldg,
s.pay_cont*rate as pay_cont,
s.pay_icc*rate as pay_icc,
to_year as dollars_in
from s join public.inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table summary.postfirm_claim_state_jurisdiction_2015a add primary key (year, state, community, jurisdiction_id);

------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.1 SUMMARY TABLE FOR PRE-FIRM POLICY in riverine flood A zone
drop table summary.prefirm_policy_state_jurisdiction_2015a;
create table summary.prefirm_policy_state_jurisdiction_2015a as
with s as (
  select
  extract(year from end_eff_dt) as year,
  re_state as state,
  re_community as community,
  jurisdiction_id,
  sum(condo_unit) as count,
  sum(t_premium) as premium,
  sum(t_cov_bldg + t_cov_cont) as t_cov,
  sum(t_cov_bldg) as t_cov_bldg,
  sum(t_cov_cont) as t_cov_cont
  from public.allpolicy a
  where post_firm = 'N'
  and fzone = 'A'
  group by 1,2,3,4
  order by 1,2,3,4)
select
s.year,
s.state,
s.community,
s.jurisdiction_id,
s.count,
s.premium*rate as premium,
s.t_cov*rate as t_cov,
s.t_cov_bldg*rate as t_cov_bldg,
s.t_cov_cont*rate as t_cov_cont,
to_year as dollars_in
from s join public.inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table summary.prefirm_policy_state_jurisdiction_2015a add primary key (year, state, community, jurisdiction_id);

-- 2.2 SUMMARY TABLE FOR POST-FIRM POLICY in riverine flood A zone
drop table summary.postfirm_policy_state_jurisdiction_2015a;
create table summary.postfirm_policy_state_jurisdiction_2015a as
with s as (
  select
  extract(year from end_eff_dt) as year,
  re_state as state,
  re_community as community,
  jurisdiction_id,
  sum(condo_unit) as count,
  sum(t_premium) as premium,
  sum(t_cov_bldg + t_cov_cont) as t_cov,
  sum(t_cov_bldg) as t_cov_bldg,
  sum(t_cov_cont) as t_cov_cont
  from public.allpolicy a
  where post_firm = 'Y'
  and fzone = 'A'
  group by 1,2,3,4
  order by 1,2,3,4)
select
s.year,
s.state,
s.community,
s.jurisdiction_id,
s.count,
s.premium*rate as premium,
s.t_cov*rate as t_cov,
s.t_cov_bldg*rate as t_cov_bldg,
s.t_cov_cont*rate as t_cov_cont,
to_year as dollars_in
from s join public.inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table summary.postfirm_policy_state_jurisdiction_2015a add primary key (year, state, community, jurisdiction_id);

------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Policy and Claim summary by state and by year
drop table us.firm_claim_policy_state_year_a;
create table us.firm_claim_policy_state_year_a as
with cpre as(
  select
  state,
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015a
  group by 1,2
  order by 1,2),
cpost as(
  select
  state,
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015a
  group by 1,2
  order by 1,2),
ppre as(
  select
  state,
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015a
  group by 1,2
  order by 1,2),
ppost as(
  select
  state,
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015a
  group by 1,2
  order by 1,2)
select
COALESCE(cpre.state, cpost.state, ppre.state, ppost.state) AS state,
COALESCE(cpre.year, cpost.year, ppre.year, ppost.year) AS year,
cpre.count as cprecount,
cpre.pay as prepay,
cpost.count as cpostcount,
cpost.pay as postpay,
ppre.count as pprecount,
ppre.premium as prepremium,
ppost.count as ppostcount,
ppost.premium as postpremium
from cpre
full join cpost using (state,year)
full join ppre using (state,year)
full join ppost using (state,year)
order by 1,2;

alter table us.firm_claim_policy_state_year_a add primary key (state,year);



------------------------------------------------------------------------------------------------------------------------------------------------
-- FIRM ratio by state for 
-- 1) post to pre firm claims for all year; 
-- 2) post to pre firm claims for overlapping years 1994-2014, normalized by policy;
-- 3) post to all firm claims for overlapping years 1994-2014, normalized by policy;
-- 4) post to all fir claims for all year
drop table us.firm_ratio_state_a;
create table us.firm_ratio_state_a as
with a as (
  select
  state,
  sum(cpostcount) as cpostcount,
  sum(cprecount) as cprecount,
  sum(postpay) as postpay,
  sum(prepay) as prepay,
  sum(cpostcount) + sum(cprecount) as callcount,
  sum(postpay) + sum(prepay) as pay
  from us.firm_claim_policy_state_year_a
  group by 1 order by 1),
b as (
  select
  state,
  sum(cpostcount) as cpostcount,
  sum(cprecount) as cprecount,
  sum(postpay) as postpay,
  sum(prepay) as prepay,
  sum(ppostcount) as ppostcount,
  sum(pprecount) as pprecount,
  sum(postpremium) as postpremium,
  sum(prepremium) as prepremium,
  sum(cpostcount) + sum(cprecount) as callcount,
  sum(ppostcount) + sum(pprecount) as pallcount,
  sum(postpay) + sum(prepay) as pay,
  sum(postpremium) + sum(prepremium) as premium
  from us.firm_claim_policy_state_year_a
  where year >= 1994 and year <= 2014
  group by 1 order by 1)
select 
a.state,
a.cpostcount/a.cprecount as ratio1,
a.postpay/a.prepay as ratio2,
a.cpostcount/a.callcount as ratio3,
a.postpay/a.pay as ratio4,
(b.cpostcount/b.ppostcount)/(b.cprecount/b.pprecount) as ratio5,
(b.postpay/b.postpremium)/(b.prepay/b.prepremium) as ratio6,
(b.cpostcount/b.ppostcount)/(b.callcount/b.pallcount) as ratio7,
(b.postpay/b.postpremium)/(b.pay/b.premium) as ratio8,
b.cpostcount/b.callcount as ratio9,
b.ppostcount/b.pallcount as ratio10,
b.postpay/b.pay as ratio11,
b.postpremium/b.premium as ratio12
from a 
join b using(state)
order by 1;

alter table us.firm_ratio_state_a add primary key (state);

select state, round( CAST(ratio3 as numeric),3) from us.firm_ratio_state_v order by 2;  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
