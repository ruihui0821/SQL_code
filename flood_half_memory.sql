Flood memory half-life

select
  effdate,
  sum(count) as count,
  sum(premium) as premium
from summary.policy_dailyeff_2015_llj p
join fima.lljpolicy l on (p.llj_id = l.llj_id)
join fima.jurisdictions j on (l.jurisdiction_id = j.jurisdiction_id)
where j.j_cid in (select n.cid from fima.nation n where county = 'ALAMEDA COUNTY')
group by 1
order by 1;
