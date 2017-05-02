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

