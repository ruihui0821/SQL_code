set search_path=summary,fima,public,us,ca;
-- ratios of policy premium to claims payment by jurisdiction
-- according to the re_state and jurisdiction_id column
drop table us.premium_pay_jurisdiction;
create table us.premium_pay_jurisdiction as
with c as (
  select jurisdiction_id, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014
  group by 1
  order by 1),
ck as (
  select jurisdiction_id, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005
  group by 1
  order by 1),
cs as (
  select jurisdiction_id, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2012
  group by 1
  order by 1),
cks as (
  select jurisdiction_id, sum(pay) as pay 
  from summary.claims_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005 and year!=2012
  group by 1
  order by 1),
p as (
  select jurisdiction_id, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014
  group by 1
  order by 1),
pk as (
  select jurisdiction_id, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005
  group by 1
  order by 1),
ps as (
  select jurisdiction_id, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2012
  group by 1
  order by 1),
pks as (
  select jurisdiction_id, sum(t_premium) as premium 
  from summary.policy_yearly_state_jurisdiction_2015
  where year>=1994 and year<=2014 and year!=2005 and year!=2012
  group by 1
  order by 1)
select
COALESCE(p.jurisdiction_id, c.jurisdiction_id) AS jurisdiction_id,
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
full outer join c using(jurisdiction_id)
full outer join pk using(jurisdiction_id)
full outer join ps using(jurisdiction_id)
full outer join pks using(jurisdiction_id)
full outer join ck using(jurisdiction_id)
full outer join cs using(jurisdiction_id)
full outer join cks using(jurisdiction_id)
order by 1;

alter table us.premium_pay_jurisdiction
add primary key(jurisdiction_id);

update us.premium_pay_jurisdiction
set ratio = 0.000001 where premium is null;
update us.premium_pay_jurisdiction
set ratio_nonk = 0.000001 where premium_nonk is null;
update us.premium_pay_jurisdiction
set ratio_nons = 0.000001 where premium_nons is null;
update us.premium_pay_jurisdiction
set ratio_nonks = 0.000001 where premium_nonks is null;

update us.premium_pay_jurisdiction
set ratio = 999999 where pay is null;
update us.premium_pay_jurisdiction
set ratio_nonk = 999999 where pay_nonk is null;
update us.premium_pay_jurisdiction
set ratio_nons = 999999 where pay_nons is null;
update us.premium_pay_jurisdiction
set ratio_nonks = 999999 where pay_nonks is null;

drop table summary.policy_claims_yearly_jurisdiction_2015;
create table summary.policy_claims_yearly_jurisdiction_2015 as
with cs as (
  select 
    jurisdiction_id,
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
    jurisdiction_id,
    year,
    sum(p.count) as pcount,
    sum(p.t_premium) as premium,
    sum(p.t_cov_bldg) as t_cov_bldg,
    sum(p.t_cov_cont) as t_cov_cont
  from summary.policy_yearly_state_jurisdiction_2015 p
  group by 1,2
  order by 1,2)
select 
COALESCE(cs.jurisdiction_id, ps.jurisdiction_id) AS jurisdiction_id,
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
full outer join ps using(jurisdiction_id, year)
order by 1, 2;

alter table summary.policy_claims_yearly_jurisdiction_2015 add primary key(jurisdiction_id,year);

drop table us.premium_pay_jurisdiction_noworst;
create table us.premium_pay_jurisdiction_noworst as
with cs as ( 
  with s as ( 
    with m as (
      select pc.jurisdiction_id, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_jurisdiction_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by 1
      order by 1)
    select 
    ps.jurisdiction_id,
    ps.year
    from summary.policy_claims_yearly_jurisdiction_2015 ps
    join m using (jurisdiction_id)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) 
  select 
  c.jurisdiction_id,
  sum(c.pay) as pay
  from summary.claims_yearly_state_jurisdiction_2015 c
  join s using (jurisdiction_id)
  where c.year>=1994 and c.year<=2014 and c.year!=s.year
  group by 1
  order by 1),
ps as ( 
  with s as ( 
    with m as (
      select pc.jurisdiction_id, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_jurisdiction_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by 1
      order by 1)
    select 
    ps.jurisdiction_id,
    ps.year
    from summary.policy_claims_yearly_jurisdiction_2015 ps
    join m using (jurisdiction_id)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) 
  select 
  p.jurisdiction_id,
  sum(p.t_premium) as premium
  from summary.policy_yearly_state_jurisdiction_2015 p
  join s using (jurisdiction_id)
  where p.year>=1994 and p.year<=2014 and p.year!=s.year
  group by 1
  order by 1)
select 
COALESCE(cs.jurisdiction_id, ps.jurisdiction_id) AS jurisdiction_id,
ps.premium,
cs.pay,
(ps.premium/cs.pay) as ratio
from ps
full outer join cs using (jurisdiction_id)
order by 1;

drop table us.premium_pay_state_jurisdiction;
create table us.premium_pay_state_jurisdiction as
select
sfc.fipsalphacode as state,
p.jurisdiction_id,
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
n.premium as premium_noworst,
n.pay as pay_noworst,
n.ratio as ratio_noworst
from us.premium_pay_jurisdiction p
full outer join us.premium_pay_jurisdiction_noworst n using (jurisdiction_id)
join fima.jurisdictions j ON (p.jurisdiction_id = j.jurisdiction_id)
join fima.statefipscodes sfc ON (sfc.fipsnumbercode = j.j_statefp10)
order by 1, 2;

alter table us.premium_pay_state_jurisdiction add column worst_year double precision;

update us.premium_pay_state_jurisdiction j
set worst_year = (
  select s.year 
  from ( 
    with m as (
      select pc.jurisdiction_id, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_jurisdiction_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by 1
      order by 1)
    select 
    ps.jurisdiction_id,
    ps.year
    from summary.policy_claims_yearly_jurisdiction_2015 ps
    join m using (jurisdiction_id)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) s where j.jurisdiction_id = s.jurisdiction_id)
where exists(
  select s.year 
  from ( 
    with m as (
      select pc.jurisdiction_id, max(pc.pay) as maxpay 
      from summary.policy_claims_yearly_jurisdiction_2015 pc
      where pc.year>=1994 and pc.year<=2014
      group by 1
      order by 1)
    select 
    ps.jurisdiction_id,
    ps.year
    from summary.policy_claims_yearly_jurisdiction_2015 ps
    join m using (jurisdiction_id)
    where ps.year>=1994 and ps.year<=2014 and ps.pay=m.maxpay
    order by 1) s where j.jurisdiction_id = s.jurisdiction_id);
