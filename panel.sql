-- dfirm_id is by county 
select c.gid, c.community, c.panel_suf, f.panel, f.suffix, f.dfirm_id, j.j_countyfp10
from public.claims c, fima.firm_panel f, fima.jurisdictions j
where substr(c.panel_suf, 1, 4) = f.panel
and substr(c.panel_suf, 5, 1) = f.suffix
and substr(f.dfirm_id, 1, 5) = j.j_countyfp10
and c.community = j.j_cid
and substr(f.dfirm_id, 6, 1) = 'C'
limit 10;

select count(distinct c.gid)
from public.claims c, fima.firm_panel f, fima.jurisdictions j
where substr(c.panel_suf, 1, 4) = f.panel
and substr(c.panel_suf, 5, 1) = f.suffix
and substr(f.dfirm_id, 1, 5) = j.j_countyfp10
and c.community = j.j_cid
and substr(f.dfirm_id, 6, 1) = 'C';

 count 
-------
 37114

-- dfirm_id is by community 
select c.gid, c.community, c.panel_suf, f.panel, f.suffix, f.dfirm_id
from public.claims c, fima.firm_panel f
where substr(c.panel_suf, 1, 4) = f.panel
and substr(c.panel_suf, 5, 1) = f.suffix
and f.dfirm_id = c.community
and substr(f.dfirm_id, 6, 1) != 'C'
limit 10;

select count(distinct c.gid)
from public.claims c, fima.firm_panel f
where substr(c.panel_suf, 1, 4) = f.panel
and substr(c.panel_suf, 5, 1) = f.suffix
and f.dfirm_id = c.community
and substr(f.dfirm_id, 6, 1) != 'C';

 count 
-------
 16601


select 37114+16601, (37114+16601)/2085015.0,  (37114+16601)/1625470.0;
 ?column? |        ?column?        |        ?column?        
----------+------------------------+------------------------
    53715 | 0.02576240458701735959 | 0.03304582674549514910

