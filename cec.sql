alter table pr_CanESM2_historical alter column year type character varying(4);
alter table pr_CanESM2_historical alter column month type character varying(2);

alter table pr_CanESM2_historical add column time date;
update pr_CanESM2_historical set time = ((year||'-'||CAST(month AS VARCHAR(2))||'-16')::date);

select year, sum(pr) as tpr from pr_CanESM2_historical where pr < 1e+020 group by 1 order by 1;


SELECT ST_Intersects('POINT(0 0)'::geometry, 'LINESTRING ( 2 0, 0 2 )'::geometry);
 st_intersects
---------------
 f
(1 row)
SELECT ST_Intersects('POINT(0 0)'::geometry, 'LINESTRING ( 0 0, 0 2 )'::geometry);
 st_intersects
---------------
 t
(1 row)


SELECT ST_Intersects(
		ST_GeographyFromText('SRID=4326;LINESTRING(-43.23456 72.4567,-43.23456 72.4568)'),
		ST_GeographyFromText('SRID=4326;POINT(-43.23456 72.4567772)')
		);

 st_intersects
---------------
t
