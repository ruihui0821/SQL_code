-- SUMMARY TABEL FOR PRE-FIRM CLAIMS
drop table summary.prefirm_claim_state_jurisdiction_2015;
create table summary.prefirm_claim_state_jurisdiction_2015 as
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

alter table summary.prefirm_claim_state_jurisdiction_2015 add primary key (year, state, community, jurisdiction_id);

-- SUMMARY TABEL FOR POST-FIRM CLAIMS
drop table summary.postfirm_claim_state_jurisdiction_2015;
create table summary.postfirm_claim_state_jurisdiction_2015 as
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

alter table summary.postfirm_claim_state_jurisdiction_2015 add primary key (year, state, community, jurisdiction_id);

------------------------------------------------------------------------------------------------------------------------------------------------
-- SUMMARY TABLE FOR PRE-FIRM POLICY
drop table summary.prefirm_policy_state_jurisdiction_2015;
create table summary.prefirm_policy_state_jurisdiction_2015 as
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

alter table summary.prefirm_policy_state_jurisdiction_2015 add primary key (year, state, community, jurisdiction_id);

-- SUMMARY TABLE FOR POST-FIRM POLICY
drop table summary.postfirm_policy_state_jurisdiction_2015;
create table summary.postfirm_policy_state_jurisdiction_2015 as
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

alter table summary.postfirm_policy_state_jurisdiction_2015 add primary key (year, state, community, jurisdiction_id);


------------------------------------------------------------------------------------------------------------------------------------------------
-- PRE & POST CLAIM SUMMARY FOR STATE
drop table us.pre_post_firm_claim_state;
create table us.pre_post_firm_claim_state as
with pre as(
  select
  year,
  state,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  group by 1, 2
  order by 1, 2),
post as(
  select
  year,
  state,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  group by 1, 2
  order by 1, 2)
select
COALESCE(pre.year, post.year) AS year,
COALESCE(pre.state, post.state) AS state,
pre.count as precount,
pre.pay as prepay,
post.count as postcount,
post.pay as postpay,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (year, state);

alter table us.pre_post_firm_claim_state add primary key(year, state);

-- PRE & POST CLAIM SUMMARY FOR COMMUNITY
drop table us.pre_post_firm_claim_community;
create table us.pre_post_firm_claim_community as
with pre as(
  select
  year,
  --state,
  community,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  group by 1, 2
  order by 1, 2),
post as(
  select
  year,
  --state,
  community,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  group by 1, 2
  order by 1, 2)
select
COALESCE(pre.year, post.year) AS year,
--COALESCE(pre.state, post.state) AS state,
n.state,
COALESCE(pre.community, post.community) AS community,
n.community_name,
n.county,
pre.count as precount,
pre.pay as prepay,
post.count as postcount,
post.pay as postpay,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (year, community)
left outer join fima.nation n on (pre.community = n.cid);

alter table us.pre_post_firm_claim_community add primary key(year, state, community);

-- By community for all years
drop table us.firm_claim_community;
create table us.firm_claim_community as
with pre as(
  select
  community,
  sum(count) as count,
  sum(pay) as pay
  from summary.prefirm_claim_state_jurisdiction_2015
  group by 1
  order by 1),
post as(
  select
  community,
  sum(count) as count,
  sum(pay) as pay
  from summary.postfirm_claim_state_jurisdiction_2015
  group by 1
  order by 1)
select
n.state,
COALESCE(pre.community, post.community) AS community,
n.community_name,
n.county,
pre.count as precount,
pre.pay as prepay,
post.count as postcount,
post.pay as postpay,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (community)
left outer join fima.nation n on (pre.community = n.cid)
order by 1, 2;

------------------------------------------------------------------------------------------------------------------------------------------------
-- PRE & POST POLICY SUMMARY FOR STATE
drop table us.pre_post_firm_policy_state;
create table us.pre_post_firm_policy_state as
with pre as(
  select
  year,
  state,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  group by 1, 2
  order by 1, 2),
post as(
  select
  year,
  state,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
  group by 1, 2
  order by 1, 2)
select
COALESCE(pre.year, post.year) AS year,
COALESCE(pre.state, post.state) AS state,
pre.count as precount,
pre.premium as prepremium,
post.count as postcount,
post.premium as postpremium,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (year, state);

alter table us.pre_post_firm_policy_state add primary key(year, state);


-- PRE & POST POLICY SUMMARY FOR COMMUNITY
drop table us.pre_post_firm_policy_community;
create table us.pre_post_firm_policy_community as
with pre as(
  select
  year,
  community,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  --where year = 2014
  group by 1, 2
  order by 1, 2),
post as(
  select
  year,
  community,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
  --where year = 2014
  group by 1, 2
  order by 1, 2)
select
COALESCE(pre.year, post.year) AS year,
n.state,
COALESCE(pre.community, post.community) AS community,
n.community_name,
n.county,
pre.count as precount,
pre.premium as prepremium,
post.count as postcount,
post.premium as postpremium,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (year, community)
left outer join fima.nation n on (pre.community = n.cid);

alter table us.pre_post_firm_policy_community add primary key(year, community);

-- By community for all years
drop table us.firm_policy_community;
create table us.firm_policy_community as
with pre as(
  select
  community,
  sum(count) as count,
  sum(premium) as premium
  from summary.prefirm_policy_state_jurisdiction_2015
  group by 1
  order by 1),
post as(
  select
  community,
  sum(count) as count,
  sum(premium) as premium
  from summary.postfirm_policy_state_jurisdiction_2015
  group by 1
  order by 1)
select
n.state,
COALESCE(pre.community, post.community) AS community,
n.community_name,
n.county,
pre.count as precount,
pre.premium as prepremium,
post.count as postcount,
post.premium as postpremium,
post.count/(pre.count + post.count) as compliance
from pre
full join post using (community)
left outer join fima.nation n on (pre.community = n.cid)
order by 1, 2;
