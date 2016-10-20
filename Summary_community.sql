set search_path=summary,fima,public,us,ca;

-- ratios of policy premium to claims payment by community
-- according to the re_state and community column
-- not making
drop table us.premium_pay_community;
create table us.premium_pay_community as
with c as (
  select community, sum(s.pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015 s
  where year>=1994 and year<=2014
  group by 1
  order by 1),
ck as (
  select community, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005
  group by 1
  order by 1),
cs as (
  select community, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2012
  group by 1
  order by 1),
cks as (
  select community, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005 and year!=2012
  group by 1
  order by 1),
p as (
  select community, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014
  group by 1
  order by 1),
pk as (
  select community, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005
  group by 1
  order by 1),
ps as (
  select community, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2012
  group by 1
  order by 1),
pks as (
  select community, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005 and year!=2012
  group by 1
  order by 1)
select
COALESCE(p.community, c.community) AS community,
p.premium, 
c.pay,
(p.premium/c.pay) as ratio,
pk.premium as premium_nonk,
ck.pay as pay_nonk,
(pk.premium/ck.pay) as ratio_nonk,
ps.premium as premium_nons,
cs.pay as pay_nons,
(ps.premium/cs.pay) as ratio_nons,
pks.premium as premium_nonks,
cks.pay as pay_nonks,
(pks.premium/cks.pay) as ratio_nonks
from p
full outer join c using(community)
full outer join pk using(community)
full outer join ps using(community)
full outer join pks using(community)
full outer join ck using(community)
full outer join cs using(community)
full outer join cks using(community)
order by 1;

alter table us.premium_pay_community
add primary key(community);

update us.premium_pay_community
set ratio = 0.000001 where premium is null;
update us.premium_pay_community
set ratio_nonk = 0.000001 where premium_nonk is null;
update us.premium_pay_community
set ratio_nons = 0.000001 where premium_nons is null;
update us.premium_pay_community
set ratio_nonks = 0.000001 where premium_nonks is null;

update us.premium_pay_community
set ratio = 999999 where pay is null;
update us.premium_pay_community
set ratio_nonk = 999999 where pay_nonk is null;
update us.premium_pay_community
set ratio_nons = 999999 where pay_nons is null;
update us.premium_pay_community
set ratio_nonks = 999999 where pay_nonks is null;

drop table summary.policy_claims_yearly_community_2015;
create table summary.policy_claims_yearly_community_2015 as
with cs as (
  select 
    community,
    year,
    sum(c.count) as ccount,
    sum(c.pay) as pay,
    sum(c.t_dmg_bldg) as t_dmg_bldg,
    sum(c.t_dmg_cont) as t_dmg_cont,
    sum(c.t_dmg) as t_dmg,
    sum(c.pay_bldg) as pay_bldg,
    sum(c.pay_cont) as pay_cont,
    sum(c.pay_icc) as pay_icc
  from summary.claims_yearly_state_jurisdiction_2015 c
  group by 1,2
  order by 1,2),
ps as (
  select
    community,
    year,
    sum(p.count) as pcount,
    sum(p.t_premium) as premium,
    sum(p.t_cov_bldg) as t_cov_bldg,
    sum(p.t_cov_cont) as t_cov_cont
  from summary.policy_yearly_state_jurisdiction_2015 p
  group by 1,2
  order by 1,2)
select 
COALESCE(cs.community, ps.community) AS community,
COALESCE(cs.year, ps.year) AS year,
cs.ccount,
cs.pay,
cs.t_dmg_bldg,
cs.t_dmg_cont,
cs.t_dmg,
cs.pay_bldg,
cs.pay_cont,
cs.pay_icc,
ps.pcount,
ps.premium,
ps.t_cov_bldg,
ps.t_cov_cont
from cs
full outer join ps using(community, year)
order by 1, 2;

alter table summary.policy_claims_yearly_community_2015 add primary key(community,year);

-- not making
drop table us.premium_pay_community_noworst;
create table us.premium_pay_community_noworst as
with cs as ( 
  with s as ( 
    with m as (
      select pc.community, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_community_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by 1
      order by 1)
    select 
    ps.community,
    ps.year
    from summary.policy_claims_yearly_community_2015 ps
    join m using (community)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) 
  select 
  c.community,
  sum(c.pay) as pay
  from summary.claims_yearly_state_jurisdiction_2015 c
  join s using (community)
  where c.year>=1994 and c.year<=2014 and c.year!=s.year
  group by 1
  order by 1),
ps as ( 
  with s as ( 
    with m as (
      select pc.community, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_community_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by 1
      order by 1)
    select 
    ps.community,
    ps.year
    from summary.policy_claims_yearly_community_2015 ps
    join m using (community)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) 
  select 
  p.community,
  sum(p.t_premium) as premium
  from summary.policy_yearly_state_jurisdiction_2015 p
  join s using (community)
  where p.year>=1994 and p.year<=2014 and p.year!=s.year
  group by 1
  order by 1)
select 
COALESCE(cs.community, ps.community) AS community,
ps.premium,
cs.pay,
(ps.premium/cs.pay) as ratio
from ps
full outer join cs using (community)
order by 1;

-- converting the us.premium_pay_state_jurisdiction to community
drop table us.premium_pay_state_community;
create table us.premium_pay_state_community as
select
p.state,
p.jurisdiction_id,
j.j_cid as community,
p.premium,
p.pay,
p.ratio,
p.premium_nonk,
p.pay_nonk,
p.ratio_nonk,
p.premium_nons,
p.pay_nons,
p.ratio_nons,
p.premium_nonks,
p.pay_nonks,
p.ratio_nonks,
p.premium_noworst,
p.pay_noworst,
p.ratio_noworst
from us.premium_pay_state_jurisdiction p
join fima.jurisdictions j using (jurisdiction_id)
order by 1, 2, 3;
