set search_path=summary,fima,public,us;

-- adding llj_id to policy data, 79,882,364
alter table public.allpolicy add column llj_id integer;
-- updating the llj_id based on jurisdiction_id, gis_lati, gis_longi, 77,483,291
update public.allpolicy a
set llj_id = (
 select lj.llj_id 
 from fima.lljpolicy lj, public.llgridpolicy g
 where a.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi limit 1)
where exists(
 select lj.llj_id 
 from fima.lljpolicy lj, public.llgridpolicy g
 where a.jurisdiction_id = lj.jurisdiction_id and
 lj.llgrid_id = g.llgrid_id and
 a.gis_lati = g.gis_lati and
 a.gis_longi = g.gis_longi);

-- updating the rest llj_id based on jurisdiction_id, select a random , 2,393,782
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
 where a.jurisdiction_id = lj.jurisdiction_id);

-- updating the rest llj_id based on gis_lati, gis_longi, select a random of the already assigned, 4,275
update public.allpolicy a
set llj_id = (
 select aa.llj_id 
 from public.allpolicy aa
 where a.gis_lati = aa.gis_lati and
 a.gis_longi = aa.gis_longi and
 aa.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select aa.llj_id 
 from public.allpolicy aa
 where a.gis_lati = aa.gis_lati and
 a.gis_longi = aa.gis_longi and
 aa.llj_id is not null);

-- updating the rest llj_id based on re_community, select a random of the already assigned, 805
update public.allpolicy a
set llj_id = (
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_community = aa.re_community and
 aa.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_community = aa.re_community and
 aa.llj_id is not null);
 
 -- updating the rest llj_id based on re_state, select a random of the already assigned, 211
update public.allpolicy a
set llj_id = (
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_state = aa.re_state and
 aa.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select aa.llj_id 
 from public.allpolicy aa
 where a.re_state = aa.re_state and
 aa.llj_id is not null);
 
---------------------------------------------------------------------------------------------------------------------------------------- 
-- adding llj_id to claims data, 1,625,472
alter table public.paidclaims add column llj_id integer;
-- updating the llj_id based on jurisdiction_id, gis_lati, gis_longi, 1,508,065
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

-- updating the rest llj_id based on jurisdiction_id, select a random, 115,685
update public.paidclaims p
set llj_id = (
 select lj.llj_id 
 from fima.llj lj
 where p.jurisdiction_id = lj.jurisdiction_id 
 order by random() limit 1)
where llj_id is null and
exists(
 select lj.llj_id 
 from fima.llj lj
 where p.jurisdiction_id = lj.jurisdiction_id);

-- updating the rest llj_id based on gis_lati, gis_longi, select a random of the already assigned, 1,554
update public.paidclaims p
set llj_id = (
 select pp.llj_id 
 from public.paidclaims pp
 where p.gis_lati = pp.gis_lati and
 p.gis_longi = pp.gis_longi and
 pp.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select pp.llj_id 
 from public.paidclaims pp
 where p.gis_lati = pp.gis_lati and
 p.gis_longi = pp.gis_longi and
 pp.llj_id is not null);
 
-- updating the rest llj_id based on re_community, select a random of the already assigned, 91
update public.paidclaims p
set llj_id = (
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_community = pp.re_community and
 pp.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_community = pp.re_community and
 pp.llj_id is not null);
 
 -- updating the rest llj_id based on re_state, select a random of the already assigned, 77
update public.paidclaims p
set llj_id = (
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_state = pp.re_state and
 pp.llj_id is not null
 order by random() limit 1)
where llj_id is null and
exists(
 select pp.llj_id 
 from public.paidclaims pp
 where p.re_state = pp.re_state and
 pp.llj_id is not null);
 




