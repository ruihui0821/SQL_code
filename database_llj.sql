set search_path=summary,fima,public,us;

from public.allpolicy a
 join llgridpolicy g using (gis_longi,gis_lati)
 join fima.jurisdictions j using (jurisdiction_id)
 join fima.lljpolicy lj using (jurisdiction_id,llgrid_id)
