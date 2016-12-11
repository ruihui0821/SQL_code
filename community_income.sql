drop table summary.jurisdiction_income;

create table summary.jurisdiction_income as
with s as (
  select 
  p.jurisdiction_id,
  p.pcount,
  p.premium
  from summary.policy_claims_yearly_jurisdiction_2015 p
  where p.year = 2014
  order by 1),
ss as (
  select
  p.jurisdiction_id,
  sum(p.ccount) as ccount,
  sum(p.pay) as pay
  from summary.policy_claims_yearly_jurisdiction_2015 p
  group by 1
  order by 1)
select j.jurisdiction_id,
j.income,
s.pcount as pcount2014,
s.premium as premium2014,
ss.ccount,
ss.pay,
jj.j_pop10,
jj.boundary
from fima.j_income j
join fima.jurisdictions jj using(jurisdiction_id)
join s using(jurisdiction_id)
join ss using(jurisdiction_id);

alter table summary.jurisdiction_income add primary key(jurisdiction_id);

alter table fima.statefipscodes add column lowmiddleincome double precision;

update fima.statefipscodes s
set lowmiddleincome = (
  select 1.2*ss.mhincome
  from fima.statefipscodes ss
  where s.fipsnumbercode = ss.fipsnumbercode);


alter table summary.jurisdiction_income add column lowincome character varying (1);
alter table summary.jurisdiction_income add column lowmiddleincome character varying (1);

update summary.jurisdiction_income ji
set lowincome = 'Y' 
where ji.income <= (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions j
  where ji.jurisdiction_id = j.jurisdiction_id and
  j.j_statefp10 = s.fipsnumbercode);
  
update summary.jurisdiction_income ji
set lowincome = 'N' 
where ji.income > (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions j
  where ji.jurisdiction_id = j.jurisdiction_id and
  j.j_statefp10 = s.fipsnumbercode);

select lowincome, count(*), count(*)/28061.0*100 as percent from summary.jurisdiction_income group by 1;

 lowincome | count |         percent         
-----------+-------+-------------------------
 Y         |  5958 | 21.23231531306795908900
 N         | 22103 | 78.76768468693204091100

select lowincome, count(*), count(*)/18491.0*100 as percent from summary.jurisdiction_income group by 1;

 lowincome | count |         percent         
-----------+-------+-------------------------
 Y         |  3552 | 19.20934508679898328900
 N         | 14939 | 80.79065491320101671100


update summary.jurisdiction_income ji
set lowmiddleincome = 'Y' 
where ji.income <= (
  select s.lowmiddleincome 
  from fima.statefipscodes s, fima.jurisdictions j
  where ji.jurisdiction_id = j.jurisdiction_id and
  j.j_statefp10 = s.fipsnumbercode);
  
update summary.jurisdiction_income ji
set lowmiddleincome = 'N' 
where ji.income > (
  select s.lowmiddleincome
  from fima.statefipscodes s, fima.jurisdictions j
  where ji.jurisdiction_id = j.jurisdiction_id and
  j.j_statefp10 = s.fipsnumbercode);

select lowmiddleincome, count(*), count(*)/28061.0*100 as percent from summary.jurisdiction_income group by 1;
 
 lowmiddleincome | count |         percent         
-----------------+-------+-------------------------
 Y               | 23303 | 83.04408253447845764600
 N               |  4758 | 16.95591746552154235400

select lowmiddleincome, count(*), count(*)/18491.0*100 as percent from summary.jurisdiction_income group by 1;

 lowmiddleincome | count |         percent         
-----------------+-------+-------------------------
 Y               | 14643 | 79.18987615596776810300
 N               |  3848 | 20.81012384403223189700


