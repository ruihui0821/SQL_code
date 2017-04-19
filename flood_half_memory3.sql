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














