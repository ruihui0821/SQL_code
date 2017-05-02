-- By state for all years
drop table us.firm_claim_state;
create table us.firm_claim_state as
with pre as(
  select
  state,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  group by 1
  order by 1),
post as(
  select
  state,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  group by 1
  order by 1)
select
COALESCE(pre.state, post.state) AS state,
pre.count as precount,
pre.pay as prepay,
post.count as postcount,
post.pay as postpay,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (state)
order by 1;

-- By state for all years
drop table us.firm_policy_state;
create table us.firm_policy_state as
with pre as(
  select
  state,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  group by 1
  order by 1),
post as(
  select
  state,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
  group by 1
  order by 1)
select
COALESCE(pre.state, post.state) AS state,
pre.count as precount,
pre.premium as prepremium,
post.count as postcount,
post.premium as postpremium,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (state)
order by 1;

-- By year for all states
with pre as(
  select
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  group by 1
  order by 1),
post as(
  select
  year,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
  group by 1
  order by 1)
select
COALESCE(pre.year, post.year) AS year,
pre.count as precount,
pre.premium as prepremium,
post.count as postcount,
post.premium as postpremium,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (year)
order by 1;

-- By year for all states
with pre as(
  select
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  group by 1
  order by 1),
post as(
  select
  year,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  group by 1
  order by 1)
select
COALESCE(pre.year, post.year) AS year,
pre.count as precount,
pre.pay as prepay,
post.count as postcount,
post.pay as postpay,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (year)
order by 1;
