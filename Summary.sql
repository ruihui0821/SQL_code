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
