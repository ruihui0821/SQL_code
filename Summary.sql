set search_path=summary,fima,public,us,ca;
-- ratios of policy premium to claims payment by state
-- according to the re_state column
drop table us.premium_pay_state;
create table us.premium_pay_state as
with c as (
  select state, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014
  group by state
  order by state),
ck as (
  select state, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005
  group by state
  order by state),
cs as (
  select state, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2012
  group by state
  order by state),
cks as (
  select state, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005 and year!=2012
  group by state
  order by state),
p as (
  select state, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014
  group by state
  order by state),
pk as (
  select state, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005
  group by state
  order by state),
ps as (
  select state, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2012
  group by state
  order by state),
pks as (
  select state, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005 and year!=2012
  group by state
  order by state)
select
COALESCE(p.state, c.state) AS state,
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
full outer join c using(state)
full outer join pk using(state)
full outer join ps using(state)
full outer join pks using(state)
full outer join ck using(state)
full outer join cs using(state)
full outer join cks using(state)
order by 1;

alter table us.premium_pay_state
add primary key(state);

update us.premium_pay_state
set ratio = 0.000001 where premium is null;
update us.premium_pay_state
set ratio_nonk = 0.000001 where premium_nonk is null;
update us.premium_pay_state
set ratio_nons = 0.000001 where premium_nons is null;
update us.premium_pay_state
set ratio_nonks = 0.000001 where premium_nonks is null;

update us.premium_pay_state
set ratio = 999999 where pay is null;
update us.premium_pay_state
set ratio_nonk = 999999 where pay_nonk is null;
update us.premium_pay_state
set ratio_nons = 999999 where pay_nons is null;
update us.premium_pay_state
set ratio_nonks = 999999 where pay_nonks is null;

drop table summary.policy_claims_yearly_state_2015;
create table summary.policy_claims_yearly_state_2015 as
select 
  COALESCE(p.state, c.state) AS state, 
  COALESCE(p.year, c.year) AS year,
  sum(c.count) as ccount,
  sum(c.pay) as pay,
  sum(c.t_dmg_bldg) as t_dmg_bldg,
  sum(c.t_dmg_cont) as t_dmg_cont,
  sum(c.t_dmg) as t_dmg,
  sum(c.pay_bldg) as pay_bldg,
  sum(c.pay_cont) as pay_cont,
  sum(c.pay_icc) as pay_icc,
  sum(p.count) as pcount,
  sum(p.t_premium) as premium,
  sum(p.t_cov_bldg) as t_cov_bldg,
  sum(p.t_cov_cont) as t_cov_cont
from summary.claims_yearly_state_jurisdiction_2015 c
full outer join summary.policy_yearly_state_jurisdiction_2015 p using(state, year)
group by 1,2
order by 1,2;

alter table summary.policy_claims_yearly_state_2015 add primary key(state,year);

drop table us.premium_pay_state_noworst;
create table us.premium_pay_state_noworst as
with cs as ( 
  with s as ( 
    with m as (
      select pc.state, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_state_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by state
      order by state)
    select 
    ps.state, 
    ps.year
    from summary.policy_claims_yearly_state_2015 ps
    join m using (state)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) 
  select 
  c.state, 
  sum(c.pay) as pay
  from summary.claims_yearly_state_jurisdiction_2015 c
  join s using (state)
  where c.year>=1994 and c.year<=2014 and c.year!=s.year
  group by 1
  order by 1),
ps as ( 
  with s as ( 
    with m as (
      select pc.state, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_state_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by state
      order by state)
    select 
    ps.state, 
    ps.year
    from summary.policy_claims_yearly_state_2015 ps
    join m using (state)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) 
  select 
  p.state, 
  sum(p.t_premium) as premium
  from summary.policy_yearly_state_jurisdiction_2015 p
  join s using (state)
  where p.year>=1994 and p.year<=2014 and p.year!=s.year
  group by 1
  order by 1)
select 
COALESCE(cs.state, ps.state) AS state,
ps.premium,
cs.pay,
(ps.premium/cs.pay) as ratio
from ps
full outer join cs using (state)
order by 1;
  
