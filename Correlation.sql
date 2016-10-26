set search_path = fima,summary, us;

-- correlation between claims, policy and population by state
-- not making
drop table summary.claims_policy_population_state;
create table summary.claims_policy_population_state as
select 
sfc.fipsalphacode as state,
sum(j.j_pop10) as population,
sum(j.shape_area) as area,
sum(p.ccount) as ccount,
sum(p.pay) as pay,
sum(p.pcount) as pcount,
sum(p.premium) as premium
from summary.policy_claims_yearly_jurisdiction_2015 p
join fima.jurisdictions j ON (p.jurisdiction_id = j.jurisdiction_id)
join fima.statefipscodes sfc ON (sfc.fipsnumbercode = j.j_statefp10)
group by 1
order by 1;
-- unit of shape_area is 10000km2


-- correlation between claims, policy and population by jurisdiciton/community
drop table summary.claims_policy_population_community;
create table summary.claims_policy_population_community as
select 
sfc.fipsalphacode as state,
j.j_cid as community_id,
j.j_namelsad10 as community_name,
j.j_pop10 as population,
j.shape_area as area,
sum(p.ccount) as ccount,
sum(p.pay) as pay,
sum(p.pcount) as pcount,
sum(p.premium) as premium
from summary.policy_claims_yearly_jurisdiction_2015 p
join fima.jurisdictions j ON (p.jurisdiction_id = j.jurisdiction_id)
join fima.statefipscodes sfc ON (sfc.fipsnumbercode = j.j_statefp10)
group by 1, 2, 3, 4, 5
order by 1, 2;
-- unit of shape_area is 10000km2


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
