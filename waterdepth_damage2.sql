
-- 1. summary of waterdepth damage
select
  waterdepth,
  sum(pay_bldg) as pay_bldg,
  sum(pay_cont) as pay_cont,
  sum(pay) as pay,
  sum(t_dmg_bldg) as dmg_bldg,
  sum(t_dmg_cont) as dmg_cont,
  sum(dmg) as dmg,
  sum(t_prop_val) as prop_val,
  sum(val_cont) as val_cont,
  sum(value) as value
  from us.waterdepth_damage_value_2015
  group by 1
  order by 1;
  
-- 2. summary of waterdepth damage by state
select
  state,
  waterdepth,
  sum(pay_bldg) as pay_bldg,
  sum(pay_cont) as pay_cont,
  sum(pay) as pay,
  sum(t_dmg_bldg) as dmg_bldg,
  sum(t_dmg_cont) as dmg_cont,
  sum(dmg) as dmg,
  sum(t_prop_val) as prop_val,
  sum(val_cont) as val_cont,
  sum(value) as value
  from us.waterdepth_damage_value_2015
  group by 1, 2
  order by 1, 2;

-- 3. summary of waterdepth damage by fzone
select
  fzone,
  waterdepth,
  sum(pay_bldg) as pay_bldg,
  sum(pay_cont) as pay_cont,
  sum(pay) as pay,
  sum(t_dmg_bldg) as dmg_bldg,
  sum(t_dmg_cont) as dmg_cont,
  sum(dmg) as dmg,
  sum(t_prop_val) as prop_val,
  sum(val_cont) as val_cont,
  sum(value) as value
  from us.waterdepth_damage_value_2015
  group by 1, 2
  order by 1, 2;

-- 4. summary of waterdepth damage by state, flood zone
select
  state,
  fzone,
  waterdepth,
  sum(pay_bldg) as pay_bldg,
  sum(pay_cont) as pay_cont,
  sum(pay) as pay,
  sum(t_dmg_bldg) as dmg_bldg,
  sum(t_dmg_cont) as dmg_cont,
  sum(dmg) as dmg,
  sum(t_prop_val) as prop_val,
  sum(val_cont) as val_cont,
  sum(value) as value
  from us.waterdepth_damage_value_2015
  group by 1, 2, 3
  order by 1, 2, 3;

-- 5. summary of waterdepth damage by state, community, flood zone
select
  state,
  community,
  fzone,
  waterdepth,
  sum(pay_bldg) as pay_bldg,
  sum(pay_cont) as pay_cont,
  sum(pay) as pay,
  sum(t_dmg_bldg) as dmg_bldg,
  sum(t_dmg_cont) as dmg_cont,
  sum(dmg) as dmg,
  sum(t_prop_val) as prop_val,
  sum(val_cont) as val_cont,
  sum(value) as value
  from us.waterdepth_damage_value_2015
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4;
