set search_path = ca,fima,public,us,summary;

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
  
drop table us.waterdepth_damage_value;
create table us.waterdepth_damage_value as
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
 
alter table us.waterdepth_damage_value add primary key (gid);

select corr(paypercent, waterdepth), corr(dmgpercent, waterdepth) from us.waterdepth_damage_value;
         corr          |         corr          
-----------------------+-----------------------
 3.26312559673119e-005 | 9.79666446154346e-006

-- paypercent
select count(*), count(*)/1587995.0, corr(paypercent, waterdepth) from us.waterdepth_damage_value where dmgpercent <=10;
  count  |        ?column?        |         corr         
---------+------------------------+----------------------
 1587516 | 0.99969836177066048697 | 0.000298499128653996

select count(*), count(*)/1587995.0, corr(paypercent, waterdepth) from us.waterdepth_damage_value where dmgpercent <=2;
  count  |        ?column?        |         corr         
---------+------------------------+----------------------
 1584996 | 0.99811145501087849773 | 0.000283937624060079

select count(*), count(*)/1587995.0, corr(paypercent, waterdepth) from us.waterdepth_damage_value where dmgpercent <=1;
  count  |        ?column?        |          corr          
---------+------------------------+------------------------
 1487206 | 0.93653065658267185980 | -3.87183610401184e-005

-- dmgpercent
select count(*), count(*)/1587995.0, corr(dmgpercent, waterdepth) from us.waterdepth_damage_value where dmgpercent <=10;
  count  |        ?column?        |       corr        
---------+------------------------+-------------------
 1587516 | 0.99969836177066048697 | 0.095958648136763

select count(*), count(*)/1587995.0, corr(dmgpercent, waterdepth)  from us.waterdepth_damage_value where dmgpercent <=2;
  count  |        ?column?        |       corr       
---------+------------------------+------------------
 1584996 | 0.99811145501087849773 | 0.10012113173859

select count(*), count(*)/1587995.0, corr(dmgpercent, waterdepth) from us.waterdepth_damage_value where dmgpercent <=1;
  count  |        ?column?        |       corr        
---------+------------------------+-------------------
 1487206 | 0.93653065658267185980 | 0.075152285329157
 

-- California
drop table ca.ca_waterdepth_damage_value_2015;
create table ca.ca_waterdepth_damage_value_2015 as
with s as (
 select
  gid,
  extract(year from dt_of_loss) as year,
  waterdepth, 
  pay_bldg,
  pay_cont,
  pay_bldg + pay_cont as pay, 
  t_dmg_bldg,
  t_dmg_cont,
  t_dmg_bldg + t_dmg_cont as dmg,
  t_prop_val,
  val_cont,
  t_prop_val + val_cont as value,
  (pay_bldg + pay_cont)/(t_prop_val + val_cont) as paypercent,
  (t_dmg_bldg + t_dmg_cont)/(t_prop_val + val_cont) as dmgpercent
from public.paidclaims
where t_prop_val+val_cont > 0 and re_state = 'CA')
select
  gid,
  waterdepth, 
  pay_bldg*rate as pay_bldg,
  pay_cont*rate as pay_cont,
  pay*rate as pay, 
  t_dmg_bldg*rate as t_dmg_bldg,
  t_dmg_cont*rate as t_dmg_cont,
  dmg*rate as dmg,
  t_prop_val*rate as t_prop_val,
  val_cont*rate as val_cont,
  value*rate as value,
  paypercent,
  dmgpercent
from s join public.inflation i on (i.from_year=s.year)
where i.to_year=2015;

alter table ca.ca_waterdepth_damage_value_2015 add primary key (gid);

select
waterdepth,
count(*),
sum(pay) as tpay,
sum(dmg) as tdmg,
sum(value) as tvalue
from ca.ca_waterdepth_damage_value_2015
group by 1
order by 1;


