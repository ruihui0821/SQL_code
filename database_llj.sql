set search_path=summary,fima,public,us;

-- adding llj_id to policy data
alter table public.allpolicy add column llj_id integer;
update public.allpolicy a
set llj_id = (
 select lj.llj_id 
 from fima.lljpolicy lj, public.llgridpolicy g
 where p.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi limit 1)
where exists(
 select lj.llj_id 
 from fima.lljpolicy lj, public.llgridpolicy g
 where p.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi);
 
update public.allpolicy a 
set llj_id = (
 select lj.llj_id 
 from fima.lljpolicy lj
 where a.jurisdiction_id = lj.jurisdiction_id 
 order by random() limit 1)
where llj_id is null and
exists(
 select lj.llj_id 
 from fima.lljpolicy lj
 join llgridpolicy g using (llgrid_id)
 where a.jurisdiction_id = lj.jurisdiction_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi limit 1);

-- adding llj_id to claims data
alter table public.paidclaims add column llj_id integer;
update public.paidclaims p
set llj_id = (
 select lj.llj_id 
 from fima.llj lj, public.llgrid g
 where p.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 p.gis_lati = g.gis_lati and
 p.gis_longi = g.gis_longi limit 1)
where exists(
 select lj.llj_id 
 from fima.llj lj, public.llgrid g
 where p.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 p.gis_lati = g.gis_lati and
 p.gis_longi = g.gis_longi);
 
update public.paidclaims p
set llj_id = (
 select lj.llj_id 
 from fima.llj lj
 where a.jurisdiction_id = lj.jurisdiction_id 
 order by random() limit 1)
where llj_id is null and
exists(
 select lj.llj_id 
 from fima.llj lj
 join llgridpolicy g using (llgrid_id)
 where a.jurisdiction_id = lj.jurisdiction_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi);
