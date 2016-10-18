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
