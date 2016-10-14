-- ratios of policy premium to claims payment by state
-- according to the re_state column
drop table us.policy_premium_claim_pay_state;
create table us.policy_premium_claim_pay_state as
with c as (
  select state, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014
  group by state
  order by state),
p as (
  select state, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014
  group by state
  order by state)
select
COALESCE(p.state, c.state) AS state,
p.premium, 
c.pay,
(p.premium/c.pay) as ratio
from p
full outer join c using(state)
order by 1;

alter table us.policy_premium_claim_pay_state
add primary key(state);

update us.policy_premium_claim_pay_state
set ratio = 0.000001 where premium is null;
update us.policy_premium_claim_pay_state
set ratio = 999999 where pay is null;
