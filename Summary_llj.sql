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

     premium     |       pay        |       ratio       | premium_noworst |   pay_noworst    |  ratio_noworst   
-----------------+------------------+-------------------+-----------------+------------------+------------------
 3502577150.2121 | 6363188132.18736 | 0.550443752007703 | 3337592327.3257 | 2205868313.84818 | 1.51305148470228

-------------------------------------------------------------------------------------------------------------------------------------
-- 3. verylowincome summary
drop table summary.policy_claims_yearly_2015_verylowincome;
create table summary.policy_claims_yearly_2015_verylowincome as
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
  where c.llj_id = li.llj_id and li.verylowincome = 'Y' 
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
  where p.llj_id = lpi.llj_id and lpi.verylowincome = 'Y' 
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

alter table summary.policy_claims_yearly_2015_verylowincome add primary key(year);

with c as (
  select sum(pay) as pay 
  from summary.policy_claims_yearly_2015_verylowincome
  where year>=1994 and year<=2014),
cs as ( 
  select
  sum(pc.pay) as pay
  from summary.policy_claims_yearly_2015_verylowincome pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_verylowincome pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) ),  
p as (
  select sum(premium) as premium 
  from summary.policy_claims_yearly_2015_verylowincome
  where year>=1994 and year<=2014),
ps as (
  select 
  sum(pc.premium) as premium
  from summary.policy_claims_yearly_2015_verylowincome pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_verylowincome pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) )
select
p.premium, 
c.pay,
(p.premium/c.pay) as ratio,
ps.premium as premium_noworst,
cs.pay as pay_noworst,
(ps.premium/cs.pay) as ratio_noworst
from p, c, ps, cs;

    premium    |       pay       |       ratio       | premium_noworst |   pay_noworst   |   ratio_noworst   
---------------+-----------------+-------------------+-----------------+-----------------+-------------------
 65097524.2441 | 91501295.565603 | 0.711438279006963 |   63056524.8649 | 74064621.951075 | 0.851371723824546
 
-------------------------------------------------------------------------------------------------------------------------------------
-- 4. lowmiddleincome summary
drop table summary.policy_claims_yearly_2015_lowmiddleincome;
create table summary.policy_claims_yearly_2015_lowmiddleincome as
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
  where c.llj_id = li.llj_id and li.lowmiddleincome = 'Y' 
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
  where p.llj_id = lpi.llj_id and lpi.lowmiddleincome = 'Y' 
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

alter table summary.policy_claims_yearly_2015_lowmiddleincome add primary key(year);

with c as (
  select sum(pay) as pay 
  from summary.policy_claims_yearly_2015_lowmiddleincome
  where year>=1994 and year<=2014),
cs as ( 
  select
  sum(pc.pay) as pay
  from summary.policy_claims_yearly_2015_lowmiddleincome pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_lowmiddleincome pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) ),  
p as (
  select sum(premium) as premium 
  from summary.policy_claims_yearly_2015_lowmiddleincome
  where year>=1994 and year<=2014),
ps as (
  select 
  sum(pc.premium) as premium
  from summary.policy_claims_yearly_2015_lowmiddleincome pc
  where pc.year>=1994 and 
        pc.year<=2014 and 
        pc.year not in ( 
        select 
        pcc.year
        from summary.policy_claims_yearly_2015_lowmiddleincome pcc
        where pcc.year>=1994 and pcc.year<=2014 order by pcc.pay desc limit 1) )
select
p.premium, 
c.pay,
(p.premium/c.pay) as ratio,
ps.premium as premium_noworst,
cs.pay as pay_noworst,
(ps.premium/cs.pay) as ratio_noworst
from p, c, ps, cs;

    ppremium      |       pay        |       ratio       | premium_noworst  |   pay_noworst    |  ratio_noworst   
------------------+------------------+-------------------+------------------+------------------+------------------
 48096093412.1524 | 50327389824.8206 | 0.955664372413612 | 45879263449.0459 | 29688496900.5498 | 1.54535487608995

2005 is the year with the largest payment
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

select effdate, max(count_capita) from us.policy_monthlyeff_2015_llj_pop10_lowincome group by 1 order by 2 desc limit 5;
  effdate   |        max         
------------+--------------------
 1999-03-31 | 11943.388255175327
 1999-02-28 | 11863.117870722433
 1999-04-30 | 11647.655259822560
 1999-05-31 | 11525.137304604985
 1999-09-30 | 11427.967891846219
 
select effdate, max(premium_capita) from us.policy_monthlyeff_2015_llj_pop10_lowincome group by 1 order by 2 desc limit 5;
  effdate   |       max        
------------+------------------
 2008-04-30 |       26056687.5
 2008-02-29 |       26056687.5
 2008-03-31 |       26056687.5
 2007-09-30 | 16707449.4166667
 2007-10-31 | 16707449.4166667
 
drop table us.claims_accum_monthly_2015_llj_pop10_lowincome;
create table us.claims_accum_monthly_2015_llj_pop10_lowincome as
select c.* 
from us.claims_accum_monthly_2015_llj_pop10 c, fima.llj_income j
where c.llj_id = j.llj_id and j.lowincome = 'Y';

-------------------------------------------------------------------------------------------------------------------------------------
-- tables for making videos for vertlowincome group
-- not making
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
