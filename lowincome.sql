set search_path = fima,us,summary;

----------------------------------------------------------------------------------------------------------------------------------------
-- poverty index, lowincome index (80% of median household income), verylowincome index (50% of median household income). 
-- 'Y' means yes, 'N' means no.
-- https://www.huduser.gov/portal/datasets/il/fmr98/sect8.html

-- hhtp://obamacarefacts.com/federal-poverty-level/
-- 2014 Federal Poverty Guidelines – 48 Contiguous States & DC
-- Persons in Household: 4
-- 2014 Federal Poverty Level threshold 100% FPL: $23,850
-- 2014 POVERTY GUIDELINES – ALASKA: $29,820  FIPS Code 02
-- 2014 POVERTY GUIDELINES – HAWAII: $27,430  FIPS Code 15

-- jurisdiction table (28061 rows))
alter table fima.j_income add column poverty character varying(1);
update fima.j_income j
set poverty = 'Y' 
where j.income <= (
  select s.poverty 
  from fima.statefipscodes s, fima.jurisdictions js
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = j.jurisdiction_id);
update fima.j_income j
set poverty = 'N' 
where j.income > (
  select s.poverty 
  from fima.statefipscodes s, fima.jurisdictions js
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = j.jurisdiction_id);

select poverty, count(*), count(*)/28061.0*100 as percent from fima.j_income group by 1; 
 poverty | count |         percent         
---------+-------+-------------------------
 Y       |   185 |  0.65927800149673924700
 N       | 27876 | 99.34072199850326075300
 
alter table fima.j_income add column lowincome character varying(1);
update fima.j_income j
set lowincome = 'Y' 
where j.income <= (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions js
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = j.jurisdiction_id);
update fima.j_income j
set lowincome = 'N' 
where j.income > (
  select s.lowincome 
  from fima.statefipscodes s, fima.jurisdictions js
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = j.jurisdiction_id);

select lowincome, count(*), count(*)/28061.0*100 as percent from fima.j_income group by 1;
 lowincome | count |         percent         
-----------+-------+-------------------------
 Y         |  5958 | 21.23231531306795908900
 N         | 22103 | 78.76768468693204091100

alter table fima.j_income add column verylowincome character varying(1);
update fima.j_income j
set verylowincome = 'Y' 
where j.income <= (
  select s.verylowincome 
  from fima.statefipscodes s, fima.jurisdictions js
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = j.jurisdiction_id);
update fima.j_income j
set verylowincome = 'N' 
where j.income > (
  select s.verylowincome 
  from fima.statefipscodes s, fima.jurisdictions js
  where s.fipsnumbercode = js.j_statefp10 and
  js.jurisdiction_id = j.jurisdiction_id);

select verylowincome, count(*), count(*)/28061.0*100 as percent from fima.j_income group by 1;
 verylowincome | count |         percent         
---------------+-------+-------------------------
 Y             |   217 |  0.77331527743131036000
 N             | 27844 | 99.22668472256868964000


-- llj table for claims data (70842 rows)
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

 
-- llj table for policy data (111486 rows)
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
