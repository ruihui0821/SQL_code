set search_path=summary,fima,public,us,ca;
-- ratios of policy premium to claims payment by llj, for poverty group
-- according to llj_id column

-- 1. poverty summary
drop table summary.policy_claims_yearly_2015_poverty;
create table summary.policy_claims_yearly_2015_poverty as
with cs as (
  select 
    c.year,
    sum(c.count) as ccount,
    sum(c.pay_bldg + c.pay_cont) as pay,
    sum(c.pay_bldg) as pay_bldg,
    sum(c.pay_cont) as pay_cont,
    sum(c.t_dmg_bldg) as t_dmg_bldg,
    sum(c.t_dmg_cont) as t_dmg_cont,
    sum(c.t_dmg_bldg + c.t_dmg_cont) as t_dmg
  from summary.claims_yearly_2015_llj c, fima.llj_income li
  where c.llj_id = li.llj_id and li.poverty = 'Y' 
  group by 1
  order by 1),
ps as (
  select
    p.year,
    sum(p.count) as pcount,
    sum(p.t_premium) as premium,
    sum(p.t_cov_bldg) as t_cov_bldg,
    sum(p.t_cov_cont) as t_cov_cont
  from summary.policy_yearly_2015_llj p, fima.lljpolicy_income lpi
  where p.llj_id = lpi.llj_id and lpi.poverty = 'Y' 
  group by 1
  order by 1)
select 
COALESCE(cs.year, ps.year) AS year,
cs.ccount,
cs.pay,
cs.pay_bldg,
cs.pay_cont,
cs.t_dmg_bldg,
cs.t_dmg_cont,
cs.t_dmg,
ps.pcount,
ps.premium,
ps.t_cov_bldg,
ps.t_cov_cont
from cs
full outer join ps using(year)
order by 1;

alter table summary.policy_claims_yearly_2015_poverty add primary key(year);

with c as (
  select sum(pay) as pay 
  from summary.policy_claims_yearly_2015_poverty
  where year>=1994 and year<=2014),
cs as ( 
  select
  sum(pc.pay) as pay
  from summary.policy_claims_yearly_2015_poverty pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_poverty pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) ),  
p as (
  select sum(premium) as premium 
  from summary.policy_claims_yearly_2015_poverty
  where year>=1994 and year<=2014),
ps as (
  select 
  sum(pc.premium) as premium
  from summary.policy_claims_yearly_2015_poverty pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_poverty pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) )
select
p.premium, 
c.pay,
(p.premium/c.pay) as ratio,
ps.premium as premium_noworst,
cs.pay as pay_noworst,
(ps.premium/cs.pay) as ratio_noworst
from p, c, ps, cs;

 premium     |       pay        |      ratio       | premium_noworst |   pay_noworst    |  ratio_noworst   
----------------+------------------+------------------+-----------------+------------------+------------------
 552720746.3464 | 221420289.624739 | 2.49625157334563 |  531018782.2453 | 174502165.814638 | 3.04304980838671
 
 
-------------------------------------------------------------------------------------------------------------------------------------
-- 2. lowincome summary
drop table summary.policy_claims_yearly_2015_lowincome;
create table summary.policy_claims_yearly_2015_lowincome as
with cs as (
  select 
    c.year,
    sum(c.count) as ccount,
    sum(c.pay_bldg + c.pay_cont) as pay,
    sum(c.pay_bldg) as pay_bldg,
    sum(c.pay_cont) as pay_cont,
    sum(c.t_dmg_bldg) as t_dmg_bldg,
    sum(c.t_dmg_cont) as t_dmg_cont,
    sum(c.t_dmg_bldg + c.t_dmg_cont) as t_dmg
  from summary.claims_yearly_2015_llj c, fima.llj_income li
  where c.llj_id = li.llj_id and li.lowincome = 'Y' 
  group by 1
  order by 1),
ps as (
  select
    p.year,
    sum(p.count) as pcount,
    sum(p.t_premium) as premium,
    sum(p.t_cov_bldg) as t_cov_bldg,
    sum(p.t_cov_cont) as t_cov_cont
  from summary.policy_yearly_2015_llj p, fima.lljpolicy_income lpi
  where p.llj_id = lpi.llj_id and lpi.lowincome = 'Y' 
  group by 1
  order by 1)
select 
COALESCE(cs.year, ps.year) AS year,
cs.ccount,
cs.pay,
cs.pay_bldg,
cs.pay_cont,
cs.t_dmg_bldg,
cs.t_dmg_cont,
cs.t_dmg,
ps.pcount,
ps.premium,
ps.t_cov_bldg,
ps.t_cov_cont
from cs
full outer join ps using(year)
order by 1;

alter table summary.policy_claims_yearly_2015_lowincome add primary key(year);

with c as (
  select sum(pay) as pay 
  from summary.policy_claims_yearly_2015_lowincome
  where year>=1994 and year<=2014),
cs as ( 
  select
  sum(pc.pay) as pay
  from summary.policy_claims_yearly_2015_lowincome pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_lowincome pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) ),  
p as (
  select sum(premium) as premium 
  from summary.policy_claims_yearly_2015_lowincome
  where year>=1994 and year<=2014),
ps as (
  select 
  sum(pc.premium) as premium
  from summary.policy_claims_yearly_2015_lowincome pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_lowincome pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) )
select
p.premium, 
c.pay,
(p.premium/c.pay) as ratio,
ps.premium as premium_noworst,
cs.pay as pay_noworst,
(ps.premium/cs.pay) as ratio_noworst
from p, c, ps, cs;

     premium     |       pay       |       ratio       | premium_noworst |   pay_noworst    |  ratio_noworst   
-----------------+-----------------+-------------------+-----------------+------------------+------------------
 7187961173.7784 | 7885411347.3974 | 0.911551833773491 | 6854110693.7024 | 4594697985.35259 | 1.49174346508793


-------------------------------------------------------------------------------------------------------------------------------------
-- tables for making videos for poverty group
-- not making yet
drop table us.policy_monthlyeff_2015_llj_pop10_poverty;
create table us.policy_monthlyeff_2015_llj_pop10_poverty as
select s.*
from us.policy_monthlyeff_2015_llj_pop10 s, fima.lljpolicy_income l
where s.llj_id = l.llj_id and l.poverty = 'Y';

drop table us.claims_accum_monthly_2015_llj_pop10_poverty;
create table us.claims_accum_monthly_2015_llj_pop10_poverty as
select c.* 
from us.claims_accum_monthly_2015_llj_pop10 c, fima.llj_income j
where c.llj_id = j.llj_id and j.poverty = 'Y';


-------------------------------------------------------------------------------------------------------------------------------------
-- tables for making videos for lowincome group
drop table us.policy_monthlyeff_2015_llj_pop10_lowincome;
create table us.policy_monthlyeff_2015_llj_pop10_lowincome as
select s.*
from us.policy_monthlyeff_2015_llj_pop10 s, fima.lljpolicy_income l
where s.llj_id = l.llj_id and l.lowincome = 'Y';

drop table us.claims_accum_monthly_2015_llj_pop10_lowincome;
create table us.claims_accum_monthly_2015_llj_pop10_lowincome as
select c.* 
from us.claims_accum_monthly_2015_llj_pop10 c, fima.llj_income j
where c.llj_id = j.llj_id and j.lowincome = 'Y';

-------------------------------------------------------------------------------------------------------------------------------------
-- tables for making videos for vertlowincome group
drop table us.policy_monthlyeff_2015_llj_pop10_verylowincome;
create table us.policy_monthlyeff_2015_llj_pop10_verylowincome as
select s.*
from us.policy_monthlyeff_2015_llj_pop10 s, fima.lljpolicy_income l
where s.llj_id = l.llj_id and l.verylowincome = 'Y';

drop table us.claims_accum_monthly_2015_llj_pop10_verylowincome;
create table us.claims_accum_monthly_2015_llj_pop10_verylowincome as
select c.* 
from us.claims_accum_monthly_2015_llj_pop10 c, fima.llj_income j
where c.llj_id = j.llj_id and j.verylowincome = 'Y';
