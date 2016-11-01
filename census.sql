set search_path = fima,us,summary;

DELETE FROM fima.national_county_subdivision;
-- import csv file data using pgAdmin3.
DELETE FROM fima.hourseholds_income_county_subdivision;
-- import csv file data using pgAdmin3.

alter table national_county_subdivision alter column countyfp type character varying(3);

alter table fima.national_county_subdivision add primary key(statefp, countyfp, cousubfp);
alter table fima.hourseholds_income_county_subdivision add primary key(id);

alter table fima.hourseholds_income_county_subdivision add column statefp character varying(2);
update fima.hourseholds_income_county_subdivision h
set statefp = (
  select substr(id2, 1, 2) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id)
where exists(
  select substr(id2, 1, 2) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id);
  
alter table fima.hourseholds_income_county_subdivision add column countyfp character varying(3);
update fima.hourseholds_income_county_subdivision h
set countyfp = (
  select substr(id2, 3, 3) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id)
where exists(
  select substr(id2, 3, 3) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id);

alter table fima.hourseholds_income_county_subdivision add column cousubfp character varying(5);
update fima.hourseholds_income_county_subdivision h
set cousubfp = (
  select substr(id2, 6, 5) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id)
where exists(
  select substr(id2, 6, 5) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id);
  
  
drop table fima.county_subdivision_income;
create table fima.county_subdivision_income as
select
h.id,
h.id2,
n.state,
n.statefp,
n.countyname,
n.countyfp,
n.cousubname,
n.cousubname as scousubname,
n.cousubfp,
h.geography,
h.total_households,
h.median_income,
n.funcstat
from fima.national_county_subdivision n
left outer join fima.hourseholds_income_county_subdivision h using(statefp, countyfp, cousubfp)
order by n.statefp, n.countyfp, n.cousubfp;

alter table fima.county_subdivision_income add primary key(statefp, countyfp, cousubfp);
  
update fima.county_subdivision_income c
set scousubname = (
  select trim(trailing ' CCD' from cousubname)
  from fima.county_subdivision_income cc
  where c.id = cc.id)
where scousubname like '%CCD' and
exists(
  select trim(trailing ' CCD' from cousubname)
  from fima.county_subdivision_income cc
  where c.id = cc.id);

  
alter table fima.nfip_community_status add column countyfp character varying(3);
-- not working
update fima.nfip_community_status n
set countyfp = (
  select s.countyfp from fima.national_county_subdivision s
  where s.countyname = n.county_name limit 1)
where exists(
  select s.countyfp from fima.national_county_subdivision s
  where s.countyname = n.county_name limit 1);

-- test
select avg(tract_2010census.cti_median_income) 
from tract_2010census, jurisdictions 
where ST_Intersects(tract_2010census.boundary,jurisdictions.boundary) and jurisdictions.j_area_id = '06J0488';

drop table fima.j_income;
create table fima.j_income as
select 
j.jurisdiction_id,
count(t.geoid10) as ntract,
avg(t.cti_median_income) as income
from tract_2010census t, jurisdictions j
where ST_Intersects(t.boundary,j.boundary) 
-- and j.j_area_id = '06J0488'
group by 1
order by 1;

