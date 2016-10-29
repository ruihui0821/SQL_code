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
  
  
  
