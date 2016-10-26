set search_path = fima,summary, us;

-- correlation between claims, policy and population by jurisdiciton/community
drop table summary.claims_policy_population;
create table summary.claims_policy_population as
select 
sfc.fipsalphacode as state,
j.j_cid as community_id,
p.year,
j.j_namelsad10 as community_name,
j.j_pop10 as population,
j.shape_area as area,
p.ccount as ccount,
p.pay as pay,
p.pcount as pcount,
p.premium as premium
from summary.policy_claims_yearly_jurisdiction_2015 p
join fima.jurisdictions j ON (p.jurisdiction_id = j.jurisdiction_id)
join fima.statefipscodes sfc ON (sfc.fipsnumbercode = j.j_statefp10)
order by 1, 2, 3;
-- unit of shape_area is 10000km2
