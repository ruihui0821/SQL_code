--create or replace function create_llgrid() RETURNS BOOLEAN
--LANGUAGE PLPGSQL AS $$
--BEGIN

create table public.llgridpolicy (
 llgrid_id serial,
 gis_longi decimal(6,1),
 gis_lati decimal(6,1),
 boundary geometry('Polygon',4326),
 unique(gis_longi,gis_lati)
);

insert into public.llgridpolicy (gis_longi,gis_lati,boundary)
with g as (
 select gis_longi as lon,gis_lati as lat,count(*)
 from public.allpolicy group by 1,2
)
select
lon as gis_longi,
lat as gis_lati,
st_setsrid(st_makebox2d(st_makepoint(lon-0.05,lat-0.05),
st_makepoint(lon+0.05,lat+0.05)),4326) as boundary
from g;

CREATE INDEX llgrid_boundary ON public.llgridpolicy USING GIST (boundary );

create table public.llgridpolicy_state as select llgrid_id,j_statefp10 from llgridpolicy g join jurisdictions j on (st_within(st_centroid(g.boundary),j.boundary));

--END;
--$$;


-- Modifications to fima.jurisdictions to make it nice;
alter table fima.jurisdictions rename objectid to jurisdiction_id;
alter table fima.jurisdictions add boundary geometry('MULTIPOLYGON',4326);
update fima.jurisdictions set boundary=st_transform(wkb_geometry,4326);
CREATE INDEX jursidictions_boundary ON fima.jurisdictions USING GIST (boundary );

drop table fima.lljpolicy;
create table fima.lljpolicy as
select
llgrid_id,
jurisdiction_id,
st_intersection(ll.boundary,st_makevalid(j.boundary)) as boundary
from llgridpolicy ll
join fima.jurisdictions j on (st_intersects(ll.boundary,j.boundary));

alter table fima.lljpolicy add column llj_id serial primary key;
alter table fima.lljpolicy add unique (llgrid_id,jurisdiction_id);
CREATE INDEX llj_boundary ON fima.lljpolicy USING GIST (boundary );

alter table fima.lljpolicy add column hectares bigint;
update fima.lljpolicy set hectares=(st_area(st_transform(boundary,2163))/10000)::bigint;

drop table fima.lljpolicy_population;
create table fima.lljpolicy_population as
with a as (
 select
  llj_id,jurisdiction_id,
  hectares,sum(hectares) OVER (partition by jurisdiction_id) as total
  from fima.lljpolicy
)
select
 llj_id,
 ((a.hectares/a.total)*j_pop10)::decimal(18,4) as pop10
 from a join fima.jurisdictions j
 using (jurisdiction_id);
 
update fima.lljpolicy_population
set pop10 = 999999999999
where pop10 = 0;






with j as (
 select j_cid as community,j_geoid10||j_source as dfirm_id
 from jurisdictions
),
c as (
 select community,count(*)
 from allpolicy
 group by 1
)
select
j.community is null as j,count(*)
from c left join j using (community) group by 1;
