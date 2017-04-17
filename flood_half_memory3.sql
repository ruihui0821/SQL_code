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
