with a as (
  select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  group by 1, 2
  order by 1, 2),
b as (
  select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  where t_premium >10000 and t_premium<15000
  group by 1, 2
  order by 1, 2),
c as (
select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  where post_firm = 'N'
  group by 1, 2
  order by 1, 2),
d as (
select
  end_eff_dt,
  extract(year from end_eff_dt) as year,
  sum(condo_unit) as policy
  from allpolicy
  where t_premium >10000 and t_premium<15000
  and post_firm = 'N'
  group by 1, 2
  order by 1, 2)
select
a.year,
sum(a.policy) as t_policy,
sum(b.policy) as policy,
sum(b.policy)/sum(a.policy) as ratio,
sum(c.policy) as t_policy_prefirm,
sum(d.policy) as policy_prefirm,
sum(d.policy)/sum(c.policy) as ratio_prefirm
from a join b using (year) join c using (year) join d using (year)
group by 1 order by 1;
