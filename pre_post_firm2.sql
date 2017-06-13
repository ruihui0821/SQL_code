-- Policy and Claim summary by state and by year
drop table us.firm_claim_policy_state_year;
create table us.firm_claim_policy_state_year as
with cpre as(
  select
  state,
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  group by 1,2
  order by 1,2),
cpost as(
  select
  state,
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  group by 1,2
  order by 1,2),
ppre as(
  select
  state,
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  group by 1,2
  order by 1,2),
ppost as(
  select
  state,
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
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

alter table us.firm_claim_policy_state_year add primary key (state,year);



------------------------------------------------------------------------------------------------------------------------------------------------
-- Policy and Claim summary by state for overlapping years 1994-2014
drop table us.firm_claim_policy_state;
create table us.firm_claim_policy_state as
with cpre as(
  select
  state,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  where year >= 1994 and year <= 2014
  group by 1
  order by 1),
cpost as(
  select
  state,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  where year >= 1994 and year <= 2014
  group by 1
  order by 1),
ppre as(
  select
  state,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  where year >= 1994 and year <= 2014
  group by 1
  order by 1),
ppost as(
  select
  state,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
  where year >= 1994 and year <= 2014
  group by 1
  order by 1)
select
COALESCE(cpre.state, cpost.state, ppre.state, ppost.state) AS state,
cpre.count as cprecount,
cpre.pay as prepay,
cpost.count as cpostcount,
cpost.pay as postpay,
ppre.count as pprecount,
ppre.premium as prepremium,
ppost.count as ppostcount,
ppost.premium as postpremium
from cpre
full join cpost using (state)
full join ppre using (state)
full join ppost using (state)
order by 1;

alter table us.firm_claim_policy_state add primary key (state);

-- Policy and Claim summary by year for all states
drop table us.firm_claim_policy_year;
create table us.firm_claim_policy_year as
with cpre as(
  select
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  group by 1
  order by 1),
cpost as(
  select
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  group by 1
  order by 1),
ppre as(
  select
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  group by 1
  order by 1),
ppost as(
  select
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
  group by 1
  order by 1)
select
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
full join cpost using (year)
full join ppre using (year)
full join ppost using (year)
order by 1;

alter table us.firm_claim_policy_year add primary key (year);

------------------------------------------------------------------------------------------------------------------------------------------------
-- FIRM ratio by state for 1) post to pre firm claims for all year; 
-- 2) post to pre firm claims for overlapping years 1994-2014, normalized by policy;
-- 3) post to all firm claims for overlapping years 1994-2014, normalized by policy
drop table us.firm_ratio_state;
create table us.firm_ratio_state as
with a as (
  select
  state,
  sum(cpostcount) as cpostcount,
  sum(cprecount) as cprecount,
  sum(postpay) as postpay,
  sum(prepay) as prepay
  from us.firm_claim_policy_state_year
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
  sum(cpostcount + cprecount) as callcount,
  sum(ppostcount + pprecount) as pallcount,
  sum(postpay + prepay) as pay,
  sum(postpremium + prepremium) as premium
  from us.firm_claim_policy_state_year
  where year >= 1994 and year <= 2014
  group by 1 order by 1)
select 
a.state,
a.cpostcount/a.cprecount as ratio1,
a.postpay/a.prepay as ratio2,
a.cpostcount/(a.cpostcount+a.cprecount) as ratio3,
a.postpay/(a.postpay+a.prepay) as ratio4,
(b.cpostcount/b.ppostcount)/(b.cprecount/b.pprecount) as ratio5,
(b.postpay/b.postpremium)/(b.prepay/b.prepremium) as ratio6,
(b.cpostcount/b.ppostcount)/(b.callcount/b.pallcount) as ratio7,
(b.postpay/b.postpremium)/(b.pay/b.premium) as ratio8
from a 
join b using(state)
order by 1;

alter table us.firm_ratio_state add primary key (state);

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
