set search_path = fima,us,summary;

DELETE FROM fima.national_county_subdivision;
-- import csv file data using pgAdmin3.
DELETE FROM fima.hourseholds_income_county_subdivision;
-- import csv file data using pgAdmin3.

alter table national_county_subdivision alter column countyfp type character varying(3);

alter table fima.national_county_subdivision add primary key(statefp, countyfp, cousubfp);
alter table fima.hourseholds_income_county_subdivision add primary key(id);

alter table fima.hourseholds_income_county_subdivision add column statefp character varying(2);
update fima.hourseholds_income_county_subdivision h
set statefp = (
  select substr(id2, 1, 2) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id)
where exists(
  select substr(id2, 1, 2) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id);
  
alter table fima.hourseholds_income_county_subdivision add column countyfp character varying(3);
update fima.hourseholds_income_county_subdivision h
set countyfp = (
  select substr(id2, 3, 3) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id)
where exists(
  select substr(id2, 3, 3) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id);

alter table fima.hourseholds_income_county_subdivision add column cousubfp character varying(5);
update fima.hourseholds_income_county_subdivision h
set cousubfp = (
  select substr(id2, 6, 5) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id)
where exists(
  select substr(id2, 6, 5) 
  from hourseholds_income_county_subdivision hh
  where h.id = hh.id);
  
  
drop table fima.county_subdivision_income;
create table fima.county_subdivision_income as
select
h.id,
h.id2,
n.state,
n.statefp,
n.countyname,
n.countyfp,
n.cousubname,
n.cousubname as scousubname,
n.cousubfp,
h.geography,
h.total_households,
h.median_income,
n.funcstat
from fima.national_county_subdivision n
left outer join fima.hourseholds_income_county_subdivision h using(statefp, countyfp, cousubfp)
order by n.statefp, n.countyfp, n.cousubfp;

alter table fima.county_subdivision_income add primary key(statefp, countyfp, cousubfp);
  
update fima.county_subdivision_income c
set scousubname = (
  select trim(trailing ' CCD' from cousubname)
  from fima.county_subdivision_income cc
  where c.id = cc.id)
where scousubname like '%CCD' and
exists(
  select trim(trailing ' CCD' from cousubname)
  from fima.county_subdivision_income cc
  where c.id = cc.id);

  
alter table fima.nfip_community_status add column countyfp character varying(3);
-- not working
update fima.nfip_community_status n
set countyfp = (
  select s.countyfp from fima.national_county_subdivision s
  where s.countyname = n.county_name limit 1)
where exists(
  select s.countyfp from fima.national_county_subdivision s
  where s.countyname = n.county_name limit 1);

-- test
select avg(tract_2010census.cti_median_income) 
from tract_2010census, jurisdictions 
where ST_Intersects(tract_2010census.boundary,jurisdictions.boundary) and jurisdictions.j_area_id = '06J0488';

drop table fima.j_income;
create table fima.j_income as
select 
j.jurisdiction_id,
count(t.geoid10) as ntract,
avg(t.cti_median_income) as income
from tract_2010census t, jurisdictions j
where ST_Intersects(t.boundary,j.boundary) 
-- and j.j_area_id = '06J0488'
group by 1
order by 1;

INSERT INTO fima.j_income VALUES
    (28058, 0.0, 0.0);
INSERT INTO fima.j_income VALUES
    (28059, 0.0, 0.0);    
INSERT INTO fima.j_income VALUES
    (28060, 0.0, 0.0);
INSERT INTO fima.j_income VALUES
    (28061, 0.0, 0.0);    

alter table fima.j_income add primary key (jurisdiction_id);

-- number of jurisdictions of each income class
select class, count(*) from fima.j_income group by 1 order by 1;
class | count 
-------+-------
 1     |    25
 2     |   211
 3     |  2069
 4     | 12074
 5     | 11046
 6     |  1912
 7     |   677
 8     |    43
 9     |     4


update fima.lljpolicy_income
set class = 1
where income <= 15000;
update fima.lljpolicy_income
set class = 2
where income > 15000 and income <= 25000;
update fima.lljpolicy_income
set class = 3
where income > 25000 and income <= 35000;
update fima.lljpolicy_income
set class = 4
where income > 35000 and income <= 50000;
update fima.lljpolicy_income
set class = 5
where income > 50000 and income <= 75000;
update fima.lljpolicy_income
set class = 6
where income > 75000 and income <= 100000;
update fima.lljpolicy_income
set class = 7
where income > 100000 and income <= 150000;
update fima.lljpolicy_income
set class = 8
where income > 150000 and income <= 200000;
update fima.lljpolicy_income
set class = 9
where income > 200000;


-- option 1: average medium income
avg(t.cti_median_income) as income
-- option 2: weighted average medium income by number of hourseholds
sum(t.cti_households * t.cti_median_income)/sum(t.cti_households) as income

drop table fima.llj_income;
create table fima.llj_income as
select 
llj.llj_id,
count(t.geoid10) as ntract,
avg(t.cti_median_income) as income,
sum(t.cti_households * t.cti_median_income)/sum(t.cti_households) as income2
from fima.tract_2010census t, fima.llj
where ST_Intersects(t.boundary,llj.boundary) 
group by 1
order by 1;

alter table fima.llj_income add primary key (llj_id);

-- number of llj units for claim database of each income class
select class, count(*) from fima.llj_income group by 1 order by 1;
class | count 
-------+-------
 1     |   135
 2     |   597
 3     |  5094
 4     | 25957
 5     | 29142
 6     |  7087
 7     |  2602
 8     |   216
 9     |    12
 
drop table fima.lljpolicy_income;
create table fima.lljpolicy_income as
select 
llj.llj_id,
count(t.geoid10) as ntract,
avg(t.cti_median_income) as income,
sum(t.cti_households * t.cti_median_income)/sum(t.cti_households) as income2
from fima.tract_2010census t, fima.lljpolicy llj
where ST_Intersects(t.boundary,llj.boundary) 
group by 1
order by 1;

alter table fima.lljpolicy_income add primary key (llj_id);

alter table fima.lljpolicy_income add column class character varying(2);

-- number of llj units for policy database of each income class
select class, count(*) from fima.lljpolicy_income group by 1 order by 1;
class | count 
-------+-------
 1     |   162
 2     |   893
 3     |  9395
 4     | 46504
 5     | 43435
 6     |  8135
 7     |  2729
 8     |   221
 9     |    12

update summary.policy_yearly_2015_j  set j_pop10  = 9999999999 where j_pop10 = 0;

drop table us.policy_yearly_j_pop10;
create table us.policy_yearly_j_pop10 as
select 
jurisdiction_id,
year,
j_pop10,
boundary,
count,
count/cast(j_pop10 as decimal(18,4)) as count_capita,
t_premium as premium,
t_premium/cast(j_pop10 as decimal(18,4)) as premium_capita,
t_cov_bldg, 
t_cov_cont,
(t_cov_bldg + t_cov_cont) as t_cov,
(t_cov_bldg + t_cov_cont)/cast(j_pop10 as decimal(18,4)) as t_cov_capita,
j.income,
j.class
from summary.policy_yearly_2015_j
join fima.j_income j using (jurisdiction_id)
order by 1,2;


drop table us.policy_yearly_llj_pop10;
create table us.policy_yearly_llj_pop10 as
select 
llj_id,
year,
lp.pop10,
boundary,
count,
count/lp.pop10 as count_capita, 
t_premium/lp.pop10 as premium_capita,
t_premium as premium,
(t_cov_bldg + t_cov_cont) as t_cov,
j.income,
j.class
from summary.policy_yearly_2015_llj
full outer join fima.lljpolicy_income j using (llj_id)
full outer join fima.lljpolicy_population lp using (llj_id)
order by 1,2;
