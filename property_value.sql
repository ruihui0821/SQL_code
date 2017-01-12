-- adding the t_prop_val (val_main + val_app) and the val_cont data from the original claims table to the paidclaims table
alter table public.paidclaims add column t_prop_val numeric(10,0);
alter table public.paidclaims add column val_cont integer;

update public.paidclaims p
set t_prop_val = (
  select c.t_prop_val 
  from public.claims c
  where p.gid = c.gid)
where exists(
  select c.t_prop_val 
  from public.claims c
  where p.gid = c.gid);

update public.paidclaims p
set val_cont = (
  select c.val_cont 
  from public.claims c
  where p.gid = c.gid)
where exists(
  select c.val_cont 
  from public.claims c
  where p.gid = c.gid);
  
drop table waterdepth_damage_value;
create table waterdepth_damage_value as
select
  gid,
  waterdepth, 
  pay_bldg + pay_cont as pay, 
  t_dmg_bldg + t_dmg_cont as dmg,
  t_prop_val + val_cont as value,
  (pay_bldg + pay_cont)/(t_prop_val + val_cont) as paypercent,
  (t_dmg_bldg + t_dmg_cont)/(t_prop_val + val_cont) as dmgpercent
from public.paidclaims
where t_prop_val+val_cont > 0;

  count  
---------
 1587995
 
alter table waterdepth_damage_value add primary key (gid);

select corr(paypercent, waterdepth), corr(dmgpercent, waterdepth) from waterdepth_damage_value;
         corr          |         corr          
-----------------------+-----------------------
 3.26312559673119e-005 | 9.79666446154346e-006

-- paypercent
select count(*), count(*)/1587995.0, corr(paypercent, waterdepth) from waterdepth_damage_value where dmgpercent <=10;
  count  |        ?column?        |         corr         
---------+------------------------+----------------------
 1587516 | 0.99969836177066048697 | 0.000298499128653996

select count(*), count(*)/1587995.0, corr(paypercent, waterdepth) from waterdepth_damage_value where dmgpercent <=2;
  count  |        ?column?        |         corr         
---------+------------------------+----------------------
 1584996 | 0.99811145501087849773 | 0.000283937624060079

select count(*), count(*)/1587995.0, corr(paypercent, waterdepth) from waterdepth_damage_value where dmgpercent <=1;
  count  |        ?column?        |          corr          
---------+------------------------+------------------------
 1487206 | 0.93653065658267185980 | -3.87183610401184e-005

-- dmgpercent
select count(*), count(*)/1587995.0, corr(dmgpercent, waterdepth) from waterdepth_damage_value where dmgpercent <=10;
  count  |        ?column?        |       corr        
---------+------------------------+-------------------
 1587516 | 0.99969836177066048697 | 0.095958648136763

select count(*), count(*)/1587995.0, corr(dmgpercent, waterdepth)  from waterdepth_damage_value where dmgpercent <=2;
  count  |        ?column?        |       corr       
---------+------------------------+------------------
 1584996 | 0.99811145501087849773 | 0.10012113173859

select count(*), count(*)/1587995.0, corr(dmgpercent, waterdepth) from waterdepth_damage_value where dmgpercent <=1;
  count  |        ?column?        |       corr        
---------+------------------------+-------------------
 1487206 | 0.93653065658267185980 | 0.075152285329157
 
