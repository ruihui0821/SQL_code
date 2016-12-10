drop table summary.jurisdiction_income;
create table summary.jurisdiction_income as
with s as (
select 
p.jurisdiction_id,
p.pcount,
p.premium
from summary.policy_claims_yearly_jurisdiction_2015 p
where year = 2014)
select j.jurisdiction_id,
j.income,
sum(pc.ccount) as ccount,
sum(pc.pay) as pay,
s.pcount as pcount2014,
s.premium as premium2014,
jj.j_pop10,
jj.boundary
from fima.j_income j
join fima.jurisdictions jj using(jurisdiction_id)
join summary.policy_claims_yearly_jurisdiction_2015 pc using(jurisdiction_id)
join s using(jurisdiciton_id);
