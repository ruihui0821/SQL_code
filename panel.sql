select c.panel_suf, f.panel, f.suffix, f.dfirm_id, j.j_countyfp10
from public.claims c, fima.firm_panel f, fima.jurisdictions j
where substr(c.panel_suf, 1, 4) = f.panel
and substr(c.panel_suf, 5, 1) = f.suffix
and substr(f.dfirm_id, 1, 5) = j.j_countyfp10
limit 10;
