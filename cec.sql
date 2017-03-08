alter table cec.canesm2_pr_historical alter column year type character varying(4);
alter table cec.canesm2_pr_historical alter column month type character varying(2);

alter table cec.canesm2_pr_historical add column time date;
update cec.canesm2_pr_historical set time = ((year||'-'||CAST(month AS VARCHAR(2))||'-16')::date);

select year, sum(pr) as tpr from cec.canesm2_pr_historical where pr < 1e+020 group by 1 order by 1;
select year, avg(tmin) as avgtmin from cec.canesm2_tasmin_rcp85 where tmin < 1e+020 group by 1 order by 1;

update cec.canesm2_pr_historical
set lon = -lon;
alter table cec.canesm2_pr_historical 
add column latlonpoint point;
UPDATE cec.canesm2_pr_historical 
SET latlonpoint=ST_SetSRID(ST_MakePoint(lon, lat),4326)::point;

ST_SetSRID(ST_MakePoint(lon, lat),4326)::geometry

drop table cec.canesm2_pr_historical_cvpm;
create table cec.canesm2_pr_historical_cvpm as
select
c.cvpm,
p.year, 
p.month, 
avg(p.pr) as avgpr
from cec.canesm2_pr_historical p, cec.cvpm_area c
where ST_Intersects(p.latlonpoint::geometry,c.geom::geometry) 
and p.pr < 1e+020
and c.cvpm = '1' and p.year = '1950' and month = '12'
group by 1, 2, 3
order by 1, 2, 3;


ST_GeometryFromText(p.lat, p.lon)
ST_Transform(c.geom,4326)


SELECT ST_Intersects('POINT(0 0)'::geometry, 'LINESTRING ( 2 0, 0 2 )'::geometry);
 st_intersects
---------------
 f

SELECT ST_Intersects(
		ST_GeographyFromText('SRID=4326;LINESTRING(-43.23456 72.4567,-43.23456 72.4568)'),
		ST_GeographyFromText('SRID=4326;POINT(-43.23456 72.4567772)')
		);

 st_intersects
---------------
t
