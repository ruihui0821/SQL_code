alter table fima.nation add column crs integer;
update fima.nation n
set crs = (
  select c.class 
  from fima.crs_class c 
  where c.cid = n.cid) 
where exists (
  select c.class 
  from fima.crs_class c 
  where c.cid = n.cid); 

update fima.nation 
set crs = 10 
where crs is null; 


drop table summary.fmhl_crs;
create table summary.fmhl_crs as
with s as (
  select
  n.state,
  n.county_name as county,
  n.cid,
  n.crs
  from fima.nation n
  where n.state in ('CA', 'LA', 'NY', 'IL')
  order by 1, 2, 3
)
select
f.state,
f.county,
avg(s.crs) as crs
from summary.fmhl f 
left outer join s using (state, county)
group by 1, 2
order by 1, 2;

alter table summary.fmhl_crs add primary key (state, county);

---------------------------------------------------------------------------------------------------------------------------------------
-- not necessary
alter table summary.fmhl add column aland double precision;
alter table summary.fmhl add column awater double precision;

update summary.fmhl f
set aland = (
  select u.aland
  from fima.us_county_2015 u
  join fima.statefipscodes s on (u.statefp = s.fipsnumbercode)
  where s.fipsalphacode = f.state
  and u.name = f.county)
where exists(
  select u.aland
  from fima.us_county_2015 u
  join fima.statefipscodes s on (u.statefp = s.fipsnumbercode)
  where s.fipsalphacode = f.state
  and u.name = f.county);

---------------------------------------------------------------------------------------------------------------------------------------

update summary.fmhl f
set awater = (
  select u.awater
  from fima.us_county_2015 u
  join fima.statefipscodes s on (u.statefp = s.fipsnumbercode)
  where s.fipsalphacode = f.state
  and u.name = f.county)
where exists(
  select u.awater
  from fima.us_county_2015 u
  join fima.statefipscodes s on (u.statefp = s.fipsnumbercode)
  where s.fipsalphacode = f.state
  and u.name = f.county);

alter table fima.us_county_2015 add column state character varying(2);
update fima.us_county_2015 u
set state = (
  select s.fipsalphacode
  from fima.statefipscodes s
  where u.statefp = s.fipsnumbercode)
where exists(
  select s.fipsalphacode
  from fima.statefipscodes s
  where u.statefp = s.fipsnumbercode);
  
drop table summary.fmhl_urban;
create table summary.fmhl_urban as
with s as (
  select
  c.state,
  c.name as county,
  u.id,
  ST_Area(ST_Intersection(c.geom, u.geom)) as urban
  from fima.us_county_2015 c, fima.us_urban_2010 u
  where ST_Intersects(c.geom::geometry,u.geom::geometry) 
  and u.state in ('CA', 'LA', 'NY', 'IL')
  group by 1, 2, 3, 4
  order by 1, 2, 3
)
select
f.state,
f.county,
uc.aland,
uc.awater,
ST_Area(uc.geom) as total,
sum(s.urban) as urban,
sum(s.urban)/ST_Area(uc.geom) as uratio
from summary.fmhl f
left outer join s using (state, county)
left outer join fima.us_county_2015 uc on (f.state = uc.state) and (f.county = uc.name)
group by 1, 2, 3, 4, 5
order by 1, 2;

alter table summary.fmhl_urban add primary key (state, county);


---------------------------------------------------------------------------------------------------------------------------------------
-- repeated counties
CA	LAKE	488	6/5/06
CA	RIVERSIDE	867	9/13/05
CA	SAN BERNARDINO	662	9/13/05
LA	IBERVILLE	273	5/6/11
with c as (
  with s as (
    select
    p.re_state as state,
    p.county,
    p.fzone,
    p.post_firm,
    extract(year from dt_of_loss) as year,
    count(p.*),
    sum(p.t_dmg_bldg) as t_dmg_bldg,
    sum(p.t_dmg_cont) as t_dmg_cont,
    sum(p.pay_bldg) as pay_bldg,
    sum(p.pay_cont) as pay_cont,
    sum(p.t_prop_val) as t_prop_val
    from public.paidclaims p
    where p.re_state in ('LA') and p.county = 'Iberville'
    and p.dt_of_loss >= ('2011-05-06'::date - interval '3 month')
    and p.dt_of_loss <= ('2011-05-06'::date + interval '9 month')
    group by 1, 2, 3, 4, 5
    order by 1, 2, 3, 4, 5)
  select
  s.state,
  s.county,
  s.fzone,
  s.post_firm,
  s.year,
  s.count,
  (s.pay_bldg + s.pay_cont)*rate as pay,
  (s.t_dmg_bldg + s.t_dmg_cont)*rate as t_dmg,
  s.t_prop_val*rate as t_prop_val,
  s.t_dmg_bldg*rate as t_dmg_bldg,
  s.t_dmg_cont*rate as t_dmg_cont,
  s.pay_bldg*rate as pay_bldg,
  s.pay_cont*rate as pay_cont,
  i.to_year as dollars_in
  from s join public.inflation i on (i.from_year=s.year) 
  where i.to_year=2015)
select
c.state,
c.county,
sum(c.count) as count,
sum(c.pay) as pay,
sum(c.t_dmg) as t_dmg,
sum(c.t_prop_val) as t_prop_val,
sum(c.t_dmg)/sum(c.t_prop_val) as damage_ratio,
sum(c.t_dmg_bldg) as t_dmg_bldg,
sum(c.t_dmg_cont) as t_dmg_cont,
sum(c.pay_bldg) as pay_bldg,
sum(c.pay_cont) as pay_cont
from c
--where fzone in ('A')
--where post_firm = 'N'
group by 1, 2;









