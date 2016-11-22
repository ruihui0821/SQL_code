set search_path = fima,us,summary;

-- poverty index, lowincome index (80% of median household income), verylowincome index (50% of median household income). 
-- 'Y' means yes, 'N' means no.
-- https://www.huduser.gov/portal/datasets/il/fmr98/sect8.html

-- hhtp://obamacarefacts.com/federal-poverty-level/
-- 2014 Federal Poverty Guidelines – 48 Contiguous States & DC
-- Persons in Household: 4
-- 2014 Federal Poverty Level threshold 100% FPL: $23,850
-- 2014 POVERTY GUIDELINES – ALASKA: $29,820  FIPS Code 02
-- 2014 POVERTY GUIDELINES – HAWAII: $27,430  FIPS Code 15

-- jurisdiction table (28061 rows), calculating the threshold for poverty, lowincome, and very lowincome
alter table fima.j_income add column poverty double precision;
update fima.j_income j
set poverty = 29820.0
where j.jurisdiction_id in (
  select js.jurisdiction_id 
  from fima.jurisdictions js
  where js.j_statefp10 = '02');
update fima.j_income j
set poverty = 27430.0
where j.jurisdiction_id in (
  select js.jurisdiction_id 
  from fima.jurisdictions js
  where js.j_statefp10 = '15');
update fima.j_income j
set poverty = 23850.0
where j.poverty is null;

alter table fima.j_income add column lowincome double precision;
update fima.j_income j
set lowincome = (
  select 0.8*jj.income 
  from fima.j_income jj
  where jj.jurisdiction_id = j.jurisdiction_id);

alter table fima.j_income add column verylowincome double precision;
update fima.j_income j
set verylowincome = (
  select 0.5*jj.income 
  from fima.j_income jj
  where jj.jurisdiction_id = j.jurisdiction_id);

----------------------------------------------------------------------------------------------------------------------------------------
-- llj table for claims data (70842 rows), classify the poverty, low-income and very-low income based on jurisdiction level medium household income
alter table fima.llj_income add column poverty character varying(1);
update fima.llj_income j
set poverty = 'Y' 
where j.income <= (
  select jj.poverty 
  from fima.j_income jj, fima.llj l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.llj_income j
set poverty = 'N' 
where j.income > (
  select jj.poverty 
  from fima.j_income jj, fima.llj l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
  
select poverty, count(*), count(*)/70842.0*100 as percent from fima.llj_income group by 1;
 poverty | count |         percent         
---------+-------+-------------------------
 Y       |   591 |  0.83425086812907597200
 N       | 70251 | 99.16574913187092402800

alter table fima.llj_income add column lowincome character varying(1);
update fima.llj_income j
set lowincome = 'Y' 
where j.income <= (
  select jj.lowincome 
  from fima.j_income jj, fima.llj l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.llj_income j
set lowincome = 'N' 
where j.income > (
  select jj.lowincome 
  from fima.j_income jj, fima.llj l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select lowincome, count(*), count(*)/70842.0*100 as percent from fima.llj_income group by 1;
 lowincome | count |         percent         
-----------+-------+-------------------------
 Y         |  3279 |  4.62861014652324892000
 N         | 67563 | 95.37138985347675108000

alter table fima.llj_income add column verylowincome character varying(1);
update fima.llj_income j
set verylowincome = 'Y' 
where j.income <= (
  select jj.verylowincome 
  from fima.j_income jj, fima.llj l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.llj_income j
set verylowincome = 'N' 
where j.income > (
  select jj.verylowincome 
  from fima.j_income jj, fima.llj l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select verylowincome, count(*), count(*)/70842.0*100 as percent from fima.llj_income group by 1;
 verylowincome | count |         percent         
---------------+-------+-------------------------
 Y             |   117 |  0.16515626323367493900
 N             | 70725 | 99.83484373676632506100

---------------------------------------------------------------------------------------------------------------------------------------- 
-- llj table for policy data (111486 rows), classify the poverty, low-income and very-low income based on jurisdiction level medium household income
alter table fima.lljpolicy_income add column poverty character varying(1);
update fima.lljpolicy_income j
set poverty = 'Y' 
where j.income <= (
  select jj.poverty 
  from fima.j_income jj, fima.lljpolicy l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.lljpolicy_income j
set poverty = 'N' 
where j.income > (
  select jj.poverty 
  from fima.j_income jj, fima.lljpolicy l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select poverty, count(*), count(*)/111486.0*100 as percent from fima.lljpolicy_income group by 1;
 poverty | count  |         percent         
---------+--------+-------------------------
 Y       |    836 |  0.74986993882639972700
 N       | 110650 | 99.25013006117360027300
 
alter table fima.lljpolicy_income add column lowincome character varying(1);
update fima.lljpolicy_income j
set lowincome = 'Y' 
where j.income <= (
  select jj.lowincome 
  from fima.j_income jj, fima.lljpolicy l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.lljpolicy_income j
set lowincome = 'N' 
where j.income > (
  select jj.lowincome 
  from fima.j_income jj, fima.lljpolicy l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select lowincome, count(*), count(*)/111486.0*100 as percent from fima.lljpolicy_income group by 1;
 lowincome | count  |         percent         
-----------+--------+-------------------------
 Y         |   5531 |  4.96116104264212546900
 N         | 105955 | 95.03883895735787453100
 
 
alter table fima.lljpolicy_income add column verylowincome character varying(1);
update fima.lljpolicy_income j
set verylowincome = 'Y' 
where j.income <= (
  select jj.verylowincome 
  from fima.j_income jj, fima.lljpolicy l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.lljpolicy_income j
set verylowincome = 'N' 
where j.income > (
  select jj.verylowincome 
  from fima.j_income jj, fima.lljpolicy l
  where jj.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select verylowincome, count(*), count(*)/111486.0*100 as percent from fima.lljpolicy_income group by 1;
 verylowincome | count  |         percent         
---------------+--------+-------------------------
 Y             |    165 |  0.14800064582099994600
 N             | 111321 | 99.85199935417900005400

----------------------------------------------------------------------------------------------------------------------------------------
-- llj table for claims data (70842 rows), classify the poverty, low-income and very-low income based on state level medium household income
-- not making
alter table fima.llj_income add column poverty character varying(1);
update fima.llj_income j
set poverty = 'Y' 
where j.income <= (
  select s.poverty 
  from fima.statefipscodes s, fima.jurisdictions js, fima.llj l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.llj_income j
set poverty = 'N' 
where j.income > (
  select s.poverty 
  from fima.statefipscodes s, fima.jurisdictions js, fima.llj l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
  
select poverty, count(*), count(*)/70842.0*100 as percent from fima.llj_income group by 1;
 poverty | count |         percent         
---------+-------+-------------------------
 Y       |   591 |  0.83425086812907597200
 N       | 70251 | 99.16574913187092402800

alter table fima.llj_income add column lowincome character varying(1);
update fima.llj_income j
set lowincome = 'Y' 
where j.income <= (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.llj l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.llj_income j
set lowincome = 'N' 
where j.income > (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.llj l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select lowincome, count(*), count(*)/70842.0*100 as percent from fima.llj_income group by 1;
 lowincome | count |         percent         
-----------+-------+-------------------------
 Y         | 13404 | 18.92097908020665706800
 N         | 57438 | 81.07902091979334293200

alter table fima.llj_income add column verylowincome character varying(1);
update fima.llj_income j
set verylowincome = 'Y' 
where j.income <= (
  select s.verylowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.llj l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.llj_income j
set verylowincome = 'N' 
where j.income > (
  select s.verylowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.llj l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select verylowincome, count(*), count(*)/70842.0*100 as percent from fima.llj_income group by 1;
 verylowincome | count |         percent         
---------------+-------+-------------------------
 Y             |   672 |  0.94858981959854323700
 N             | 70170 | 99.05141018040145676300

---------------------------------------------------------------------------------------------------------------------------------------- 
-- llj table for policy data (111486 rows), classify the poverty, low-income and very-low income based on state level medium household income
-- not making
alter table fima.lljpolicy_income add column poverty character varying(1);
update fima.lljpolicy_income j
set poverty = 'Y' 
where j.income <= (
  select s.poverty 
  from fima.statefipscodes s, fima.jurisdictions js, fima.lljpolicy l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.lljpolicy_income j
set poverty = 'N' 
where j.income > (
  select s.poverty 
  from fima.statefipscodes s, fima.jurisdictions js, fima.lljpolicy l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select poverty, count(*), count(*)/111486.0*100 as percent from fima.lljpolicy_income group by 1;
 poverty | count  |         percent         
---------+--------+-------------------------
 Y       |    836 |  0.74986993882639972700
 N       | 110650 | 99.25013006117360027300
 
alter table fima.lljpolicy_income add column lowincome character varying(1);
update fima.lljpolicy_income j
set lowincome = 'Y' 
where j.income <= (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.lljpolicy l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.lljpolicy_income j
set lowincome = 'N' 
where j.income > (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.lljpolicy l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select lowincome, count(*), count(*)/111486.0*100 as percent from fima.lljpolicy_income group by 1;
 lowincome | count |         percent         
-----------+-------+-------------------------
 Y         | 24011 | 21.53723337459411944100
 N         | 87475 | 78.46276662540588055900
 
 
alter table fima.lljpolicy_income add column verylowincome character varying(1);
update fima.lljpolicy_income j
set verylowincome = 'Y' 
where j.income <= (
  select s.verylowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.lljpolicy l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);
update fima.lljpolicy_income j
set verylowincome = 'N' 
where j.income > (
  select s.verylowincome 
  from fima.statefipscodes s, fima.jurisdictions js, fima.lljpolicy l
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = l.jurisdiction_id and
  l.llj_id = j.llj_id);

select verylowincome, count(*), count(*)/111486.0*100 as percent from fima.lljpolicy_income group by 1;
 verylowincome | count  |         percent         
---------------+--------+-------------------------
 Y             |    949 |  0.85122795687350878100
 N             | 110537 | 99.14877204312649121900
