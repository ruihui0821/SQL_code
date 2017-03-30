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
  
drop table us.waterdepth_damage_value_2015;
create table us.waterdepth_damage_value_2015 as
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
where t_prop_val+val_cont > 0 and t_dmg_bldg + t_dmg_cont > 0)
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

  count  
---------
 1584036
 
alter table us.waterdepth_damage_value_2015 add primary key (gid);

select
waterdepth,
count(*),
sum(pay) as tpay,
sum(dmg) as tdmg,
sum(value) as tvalue
from us.waterdepth_damage_value_2015
group by 1
order by 1;


select count(*), count(*)/1584036.0 from us.waterdepth_damage_value_2015 where waterdepth >=-1 and waterdepth <= 1;
 836131 | 0.52784848324154249020

select count(*), count(*)/1584036.0 from us.waterdepth_damage_value_2015 where waterdepth >=-3 and waterdepth <= 3;
 1080815 | 0.68231719481122903772
 
select count(*), count(*)/1584036.0 from us.waterdepth_damage_value_2015 where waterdepth >=-10 and waterdepth <= 10;
 1322734 | 0.83504036524422424743

select count(*), count(*)/1584036.0 from us.waterdepth_damage_value_2015 where waterdepth >=-20 and waterdepth <= 20;
 1385111 | 0.87441888946968376981

select count(*), count(*)/1584036.0 from us.waterdepth_damage_value_2015 where waterdepth >=-30 and waterdepth <= 30;
 1411779 | 0.89125436543108868738

select count(*), count(*)/1584036.0 from us.waterdepth_damage_value_2015 where waterdepth >=-10 and waterdepth <= 30;
 1410893 | 0.89069503470880712307

select count(*), count(*)/1584036.0 from us.waterdepth_damage_value_2015 where waterdepth >=0 and waterdepth <= 30;
 1330693 | 0.84006487226300412364



select corr(paypercent, waterdepth), corr(dmgpercent, waterdepth) from us.waterdepth_damage_value_2015;
 5.52721707303675e-005 | 1.03955922401425e-005

-- paypercent
select count(*), count(*)/1584036.0, corr(paypercent, waterdepth) from us.waterdepth_damage_value_2015 where dmgpercent <=10;
 1583557 | 0.99969760788264913171 | 0.00126842930147658

select count(*), count(*)/1584036.0, corr(paypercent, waterdepth) from us.waterdepth_damage_value_2015 where dmgpercent <=2;
 1581037 | 0.99810673494794310230 | 0.00123617649630611

select count(*), count(*)/1584036.0, corr(paypercent, waterdepth) from us.waterdepth_damage_value_2015 where dmgpercent <=1;
 1483247 | 0.93637202689837857220 | 0.000511352900448155

-- dmgpercent
select count(*), count(*)/1584036.0, corr(dmgpercent, waterdepth) from us.waterdepth_damage_value_2015 where dmgpercent <=10;
 1583557 | 0.99969760788264913171 | 0.0963274975196068

select count(*), count(*)/1584036.0, corr(dmgpercent, waterdepth)  from us.waterdepth_damage_value_2015 where dmgpercent <=2;
 1581037 | 0.99810673494794310230 | 0.100515307073933

select count(*), count(*)/1584036.0, corr(dmgpercent, waterdepth) from us.waterdepth_damage_value_2015 where dmgpercent <=1;
 1483247 | 0.93637202689837857220 | 0.0755997320264223
 

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


alter table ca.ca_waterdepth_damage_value_2015 add column cid character varying(6);
update ca.ca_waterdepth_damage_value_2015 cw 
set cid = (select c.re_community from ca.capaidclaims c where c.gid = cw.gid) 
where exists (select c.re_community from ca.capaidclaims c where c.gid = cw.gid);

alter table ca.ca_waterdepth_damage_value_2015 add column jurisdiction_id integer;
update ca.ca_waterdepth_damage_value_2015 cw 
set jurisdiction_id = (select c.jurisdiction_id from ca.capaidclaims c where c.gid = cw.gid) 
where exists (select c.jurisdiction_id from ca.capaidclaims c where c.gid = cw.gid);

drop table ca.ca_waterdepth_damage_community;
create table ca.ca_waterdepth_damage_community as
select 
c.cid,
j.boundary,
j.j_pop10,
ji.income,
c.waterdepth,
count(*),
sum(c.pay) as tpay,
sum(c.dmg) as tdmg,
sum(c.value) as tvalue
from ca.ca_waterdepth_damage_value_2015 c
join fima.jurisdictions j using (jurisdiction_id)
join fima.j_income ji using (jurisdiction_id)
group by 1, 2, 3, 4, 5
order by 1, 2, 3, 4, 5;

alter table ca.ca_waterdepth_damage_community add primary key(cid, waterdepth);



