alter table cec.canesm2_pr_historical alter column year type character varying(4);
alter table cec.canesm2_pr_historical alter column month type character varying(2);

alter table cec.canesm2_pr_historical add column time date;
update cec.canesm2_pr_historical set time = ((year||'-'||CAST(month AS VARCHAR(2))||'-16')::date);

update cec.canesm2_pr_historical set month = to_char(time,'MM');

--select year, sum(pr) as tpr from cec.canesm2_pr_historical where pr < 1e+020 group by 1 order by 1;
--select year, avg(tmin) as avgtmin from cec.canesm2_tasmin_rcp85 where tmin < 1e+020 group by 1 order by 1;

update cec.canesm2_pr_historical set lon = lon - 360;
alter table cec.canesm2_pr_historical add column geom geometry;
UPDATE cec.canesm2_pr_historical 
SET geom=ST_SetSRID(ST_MakePoint(lon, lat),4326)::geometry;

----------------------------------------------------------------------------------------------------------------------------------------
-- aggregation for cvpm regions
--- 1.1 Aggregated table for historical precipitation
drop table cecagg.canesm2_pr_historical_cvpm;
create table cecagg.canesm2_pr_historical_cvpm as
select
c.cvpm,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.cvpm_area c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.pr < 1e+020
--and c.cvpm = '1' and p.year = '1950' and month = '12'
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_pr_historical_cvpm add primary key (cvpm, year, month);

---1.2 Aggregated table for historical min temperature
drop table cecagg.canesm2_tasmin_historical_cvpm;
create table cecagg.canesm2_tasmin_historical_cvpm as
select
c.cvpm,
p.year, 
p.month, 
avg(p.tmin) as avgtmin
from cec.canesm2_tasmin_historical p, cec.cvpm_area c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmin < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmin_historical_cvpm add primary key (cvpm, year, month);

---1.3 Aggregated table for historical max temperature
drop table cecagg.canesm2_tasmax_historical_cvpm;
create table cecagg.canesm2_tasmax_historical_cvpm as
select
c.cvpm,
p.year, 
p.month, 
avg(p.tmax) as avgtmax
from cec.canesm2_tasmax_historical p, cec.cvpm_area c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmax < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmax_historical_cvpm add primary key (cvpm, year, month);

---1.4 Aggregated table for rcp85 precipitation
drop table cecagg.canesm2_pr_rcp85_cvpm;
create table cecagg.canesm2_pr_rcp85_cvpm as
select
c.cvpm,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_rcp85 p, cec.cvpm_area c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.pr < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_pr_rcp85_cvpm add primary key (cvpm, year, month);

---1.5 Aggregated table for rcp85 min temperature
drop table cecagg.canesm2_tasmin_rcp85_cvpm;
create table cecagg.canesm2_tasmin_rcp85_cvpm as
select
c.cvpm,
p.year, 
p.month, 
avg(p.tmin) as avgtmin
from cec.canesm2_tasmin_rcp85 p, cec.cvpm_area c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmin < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmin_rcp85_cvpm add primary key (cvpm, year, month);

---1.6 Aggregated table for rcp85 max temperature
drop table cecagg.canesm2_tasmax_v_cvpm;
create table cecagg.canesm2_tasmax_rcp85_cvpm as
select
c.cvpm,
p.year, 
p.month, 
avg(p.tmax) as avgtmax
from cec.canesm2_tasmax_rcp85 p, cec.cvpm_area c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmax < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmax_rcp85_cvpm add primary key (cvpm, year, month);

---
select
pr.*,
tmin.avgtmin,
tmax.avgtmax,
((pr.year||'-'||CAST(pr.month AS VARCHAR(2))||'-16')::date) as time
from cecagg.canesm2_pr_historical_cvpm pr
join cecagg.canesm2_tasmin_historical_cvpm tmin using (cvpm, year, month)
join cecagg.canesm2_tasmax_historical_cvpm tmax using (cvpm, year, month)
order by cvpm, year, month;

select
pr.*,
tmin.avgtmin,
tmax.avgtmax,
((pr.year||'-'||CAST(pr.month AS VARCHAR(2))||'-16')::date) as time
from cecagg.canesm2_pr_rcp85_cvpm pr
join cecagg.canesm2_tasmin_rcp85_cvpm tmin using (cvpm, year, month)
join cecagg.canesm2_tasmax_rcp85_cvpm tmax using (cvpm, year, month)
order by cvpm, year, month;


----------------------------------------------------------------------------------------------------------------------------------------
-- aggregation for groundwaterbasins in central valley
--- 2.1 Aggregated table for historical precipitation
drop table cecagg.canesm2_pr_historical_gwcv;
create table cecagg.canesm2_pr_historical_gwcv as
select
c.id,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.groundwaterbasins_cv c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.pr < 1e+020
-- and c.id = '1' and p.year = '1950' and month = '12'
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_pr_historical_gwcv add primary key (id, year, month);

---1.2 Aggregated table for historical min temperature
drop table cecagg.canesm2_tasmin_historical_gwcv;
create table cecagg.canesm2_tasmin_historical_gwcv as
select
c.id,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.groundwaterbasins_cv c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmin < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmin_historical_gwcv add primary key (id, year, month);

---1.3 Aggregated table for historical max temperature
drop table cecagg.canesm2_tasmax_historical_gwcv;
create table cecagg.canesm2_tasmax_historical_gwcv as
select
c.id,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.groundwaterbasins_cv c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmax < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmax_historical_gwcv add primary key (id, year, month);

---1.4 Aggregated table for rcp85 precipitation
drop table cecagg.canesm2_pr_rcp85_gwcv;
create table cecagg.canesm2_pr_rcp85_gwcv as
select
c.id,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.groundwaterbasins_cv c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.pr < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_pr_rcp85_gwcv add primary key (id, year, month);

---1.5 Aggregated table for rcp85 min temperature
drop table cecagg.canesm2_tasmin_rcp85_gwcv;
create table cecagg.canesm2_tasmin_rcp85_gwcv as
select
c.id,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.groundwaterbasins_cv c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmin < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmin_rcp85_gwcv add primary key (id, year, month);

---1.6 Aggregated table for rcp85 max temperature
drop table cecagg.canesm2_tasmax_rcp85_gwcv;
create table cecagg.canesm2_tasmax_rcp85_gwcv as
select
c.id,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.groundwaterbasins_cv c
where ST_Intersects(p.geom::geometry,c.geom::geometry) 
and p.tmax < 1e+020
group by 1, 2, 3
order by 1, 2, 3;

alter table cecagg.canesm2_tasmax_rcp85_gwcv add primary key (id, year, month);

---
select
pr.*,
tmin.avgtmin,
tmax.avgtmax,
((pr.year||'-'||CAST(pr.month AS VARCHAR(2))||'-16')::date) as time
from cecagg.canesm2_pr_historical_gwcv pr
join cecagg.canesm2_tasmin_historical_gwcv tmin using (id, year, month)
join cecagg.canesm2_tasmax_historical_gwcv tmax using (id, year, month)
order by id, year, month;

select
pr.*,
tmin.avgtmin,
tmax.avgtmax,
((pr.year||'-'||CAST(pr.month AS VARCHAR(2))||'-16')::date) as time
from cecagg.canesm2_pr_rcp85_gwcv pr
join cecagg.canesm2_tasmin_rcp85_gwcv tmin using (id, year, month)
join cecagg.canesm2_tasmax_rcp85_gwcv tmax using (id, year, month)
order by id, year, month;




