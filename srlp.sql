select commname, commno, count(*) from srlp where commno not in (select j.j_cid from fima.jurisdictions j) group by 1,2 order by 3 desc;
                  commname                   | commno | count 
---------------------------------------------+--------+-------
 PENSACOLA BEACH-SANTA ROSA ISLAND AUTHORITY | 125138 |   228
 NEW JERSEY MEADOWLANDS COMMISSION           | 340570 |     8
 SENECA NATION OF INDIANS                    | 361591 |     4
 WEST HELENA, CITY OF                        | 050171 |     3
 BROOKHAVEN, CITY OF                         | 135175 |     2
 METROPOLITAN DADE COUNTY*                   | 125098 |     2
 CHATEAU WOODS, CITY OF                      | 481537 |     1
 AUGUSTA, CITY OF                            | 130159 |     1
 FAYETTE CO. W.C.& I.D.-MONUMENT HILL        | 481565 |     1
 FAYETTE COUNTY*                             | 210066 |     1
(10 rows)

12:Florida
125138#, PENSACOLA BEACH-SANTA ROSA ISLAND AUTHORITY, ESCAMBIA COUNTY
-- change to 120082 PENSACOLA, CITY OF ESCAMBIA COUNTY

34: New Jersey
340570#, NEW JERSEY MEADOWLANDS COMMISSION,  BERGEN COUNTY
The Hackensack Meadowlands Commission was renamed the New Jersey Meadowlands Commission on August 27, 2001.
-- change to 340039, HACKENSACK, CITY OF BERGEN COUNTY
36: New York
361591#, SENECA NATION OF INDIANS CATTARAUGUS COUNTY/ERIE COUNTY/CHAUTAUQUA COUNTY/ALLEGANY COUNTY
-- change to 361367 CATTARAUGUS, VILLAGE OF CATTARAUGUS COUNTY
05: ARKANSAS
050171
050168#, HELENA-WEST HELENA, CITY OF Helena and West Helena have consolidated into a single government. The name of the new community is "Helena-West Helena". Use CID 050168 for all policies in the former communities of "Helena" (CID 050168) and "West Helena" (CID 050171). The Initia, 
PHILLIPS COUNTY
-- change to 050168
13: Geogia
135175#, BROOKHAVEN, CITY OF BROOKHAVEN IS LOCATED ON DEKALB COUNTY FIRM PANELS: 0011J, 0012J, 0013J, 0014J, AND 0016J DATED 05/16/2013. The inital FIRM date for Brookhaven is 05/15/1980.
DEKALB COUNTY
-- change to 130065, 130065# DEKALB COUNTY * DEKALB COUNTY
48: Texas
481565#, FAYETTE CO. W.C.& I.D.-MONUMENT HILL, FAYETTE COUNTY
-- change to 480815, 480815# FAYETTE COUNTY* FAYETTE COUNTY

130159
-- change to 130158, 130158# AUGUSTA-RICHMOND COUNTY, CITY OF, RICHMOND COUNTY, The City of Augusta and Richmond County Consolidated into a new community The City of Augusta- Richmond County.

210066
-- change to 210067, 210067# LEXINGTON-FAYETTE URBAN COUNTY GOVERNMENT, FAYETTE COUNTY

125098
-- change to 120635, 120635# MIAMI-DADE COUNTY*, MIAMI-DADE COUNTY, INCLUDES THE UNINCORPORATED AREAS ONLY

481537
-- change to 480484# CONROE, CITY OF, MONTGOMERY COUNTY

210120: LOUISVILLE-JEFFERSON COUNTY METRO GOVERNMENT
14400;"21J0255";"21";"";"40222";"2140222";"Jeffersontown";"Jeffersontown city";"25";4;"210120";"JEFFERSONTOWN, CITY OF";"Previous CID 210121 (USE CID 210120)";26595;"P";0.452760777253028;0.00265332867125584;"0106000020E610000001000000010300000003000000600300002C077AA86D6455C0B0ADD85F761F434050AA44D95B6455C020761893FE1E43406D54A703596455C05849D6E1E81E4340E4B8533A586455C038005471E31E4340148BDF14566455C0C81AA034D41E4340A117B5FB556455C0F8D286C3D21E4340ACC56E9F5564 (...)";2578;1031
14421;"21J0510";"21";"";"81624";"2181624";"West Buechel";"West Buechel city";"25";4;"210120";"WEST BUECHEL, CITY OF";"Previous CID 210264 (USE CID 210120)";1230;"P";0.0555634681575165;0.000160224044752765;"0106000020E61000000100000001030000000100000093000000048ECBB8A96A55C0507D923B6C184340589A5B21AC6A55C0C8E13E726B184340403EE8D9AC6A55C0506E14596B184340708E3A3AAE6A55C008D1CC936B1843405CA10F96B16A55C0E8EB6B5D6A184340FC1D51A1BA6A55C0D03A55BE67184340C8A8328CBB6A (...)";156;788
12716;"21J0254";"21";"21111";"";"21111";"Jefferson";"Jefferson County";"06";4;"210120";"LOUISVILLE-JEFFERSON COUNTY METRO GOVERNMENT";"Louisville and Jefferson County have consolidated into a single government.  Use CID 210120 for all policies in the County, regardless of which jurisdiction it is in.";597337;"C";4.86064545473823;0.091131639367047;"0106000020E61000001D000000010300000001000000160000000022C495B36455C04043AA285E1743402C9276A38F6455C0C87ADCB75A174340A42A6D718D6455C06872A3C85A174340987CB3CD8D6455C070463F1A4E174340309D9D0C8E6455C0F84D9A0645174340A45EB7088C6455C0A045611745174340D440F3397764 (...)";88576;674
14360;"21J0449";"21";"";"70284";"2170284";"Shively";"Shively city";"25";4;"210120";"SHIVELY, CITY OF";"Previous CID 210124 (USE CID 210120)";15264;"P";0.245541645731913;0.00121975930444626;"0106000020E610000001000000010300000001000000D0010000583B5112127255C050551344DD1B434098EC9FA7017255C018381268B01B43406C4221020E7255C018FE45D0981B43403CF50F22197255C0F08502B6831B4340A877B81D1A7255C0409A5C8C811B43406854E0641B7255C0D04BFE277F1B43409C95B4E21B72 (...)";1185;1288
14363;"21J0469";"21";"";"67944";"2167944";"St. Matthews";"St. Matthews city";"25";4;"210120";"ST. MATTHEWS, CITY OF";"Previous CID 210123 (USE CID 210120)";17472;"P";0.395654589557088;0.00115180105170257;"0106000020E610000001000000010300000004000000DC02000044382D78D16655C0B02C0ABB2822434004323B8BDE6655C0506F7F2E1A22434014080264E86655C0182043C70E224340A8CFD556EC6655C0286ADB300A2243409C245D33F96655C0C8AC50A4FB214340FCB1101D026755C0886C921FF1214340A8D557570567 (...)";1118;1562

750000:
75 jurisdictions in PUERTO RICO, COMMONWEALTH OF

For communities with SRLP, getting 
state, cid, commname/community name 
the total proplosses/number, prop_value/property value, paid/dollar paid claims of SRLP, 
total historic ccount/number, pay/dollar paid claims, t_dmg/totdal damage of the community,
total policies-in-force, policy premium of the community in 2014,
j_pop10/population, 
income/medium household income,

drop table summary.srlp_summary;
create table summary.srlp_summary as
with 
s as (
  select
  cid,
  count(*),
  sum(proplosses) as proplosses,
  sum(prop_value) as prop_value,
  sum(paid) as paid
  from public.srlp
  where cid not in ('210120','720000')
  group by 1
  order by 1),
c as (
  select
  community,
  sum(ccount) as ccount,
  sum(pay) as pay,
  sum(t_dmg) as t_dmg
  from summary.policy_claims_yearly_community_2015
  where community not in ('210120','720000')
  group by 1
  order by 1),
p as (
  select
  community,
  pcount,
  premium,
  t_cov_bldg+t_cov_cont as t_cov
  from summary.policy_claims_yearly_community_2015
  where community not in ('210120','720000') and year = '2014'
  order by 1)
select
n.state,
n.county,
s.cid,
n.community_name,
s.count as srlp_count,
s.proplosses as srlp_proplosses,
s.proplosses/s.count as srlp_avg_proplosses,
s.prop_value as srlp_prop_value,
s.paid as srlp_paid,
s.paid/s.count as srlp_avg_paid,
c.ccount as allclaims_count,
c.pay as allclaims_paid,
c.t_dmg as allclaims_total_damage,
p.pcount as policy2014_count,
p.premium as policy2014_premium,
p.t_cov as policy2014_total_coverage,
j.j_pop10 as population2010,
ji.income as median_household_income2015
from s
join c on (s.cid = c.community)
join p on (s.cid = p.community)
join fima.jurisdictions j on (s.cid = j.j_cid)
join fima.j_income ji on (j.jurisdiction_id = ji.jurisdiction_id)
join fima.nation n on (s.cid = n.cid)
order by 1;

alter table summary.srlp_summary add primary key (cid);


select
j.j_cid,
sum(j.j_pop10) as population,
sum(ji.income*j.j_pop10)/sum(j.j_pop10) as income
from fima.jurisdictions j
join fima.j_income ji on (j.jurisdiction_id = ji.jurisdiction_id)
where j.j_cid in ('210120','720000')
group by 1
order by 1;

select j_cid, count(*) from fima.jurisdictions group by 1 order by 2 desc;
 j_cid  | count 
--------+-------
 000000 |  1008
 720000 |    75
 210120 |     5

Occupancy Type (occupancy):
1 - Single-Family
2 - Two-to-Four-Family
3 - Other Residential
4 - Nonresidential

alter table public.allpolicy add column occupancy character varying(1);
update public.allpolicy a
set occupancy  = (
  select occupancy
  from p2014 p
  where a.gid = p.gid)
where a.ptable = 'p2014' and
exists (
  select occupancy
  from p2014 p
  where a.gid = p.gid);

Rental Property Indicator (rent_prop):
Indicates if the property is a rental property.
Y-Yes
N-No

alter table public.allpolicy add column rent_prop character varying(1);
update public.allpolicy a
set rent_prop  = (
  select rent_prop
  from p2014 p
  where a.gid = p.gid)
where a.ptable = 'p2014' and
exists (
  select rent_prop
  from p2014 p
  where a.gid = p.gid);


drop table us.pilot_community;
create table us.pilot_community as
with a as (
  select 
  re_community as cid,
  sum(condo_unit) as count
  from public.allpolicy
  where ptable = 'p2014' and 
  occupancy = '1' and
  re_community not in ('210120','720000')
  group by 1),
b as (
  select 
  re_community as cid,
  sum(condo_unit) as count
  from public.allpolicy
  where ptable = 'p2014' and 
  rent_prop = 'N' and
  re_community not in ('210120','720000')
  group by 1),
q as (
  select
  cid,
  count(*)
  from public.srlp
  where paid >= (prop_value/2) and
  cid not in ('210120','720000')
  group by 1
  order by 1)
select 
s.*,
q.count as srlp_paid50_count,
c.precount as allclaims_prefirm_count,
c.prepay as allclaims_prefirm_paid,
c.postcount as allclaims_postfirm_count,
c.postpay as allclaims_postfirm_paid,
(1 - c.compliance) as allclaims_prefirm_percent,
p.precount as policy2014_prefirm_count,
p.prepremium as policy2014_prefirm_premium,
p.postcount as policy2014_postfirm_count,
p.postpremium as policy2014_postfrim_premium,
(1 - p.compliance) as policy2014_prefirm_percent,
a.count as policy2014_single_family_count,
a.count/s.policy2014_count as policy2014_single_family_percent,
b.count as policy2014_owner_occupied_count,
b.count/s.policy2014_count as policy2014_onwer_occupied_percent
from summary.srlp_summary s
join us.firm_claim_community c on (s.cid = c.community)
join us.pre_post_firm_policy_community p on (s.cid = p.community)
join a on (a.cid = s.cid)
join b on (b.cid = s.cid)
join q on (q.cid = s.cid);

drop table public.srlp_date;
create table public.srlp_date as
select 
statename, commname, commno, proplocatr, insured, city, state, zipcode, 
notspecsw, nobldgsw, floodprsw, gt100sw, unablidsw, box1sw, box2sw, box3sw, box4sw, histbldsw,
dtloss01, pay_bldg01, pay_cont01,
filler01, pval_ind, ident_dt, occupancy, post_firm, zone, prop_value, building, contents, proplosses, loss_5000, paid, average, tgt_ind, cid
from public.srlp
where dtloss01 is not null or pay_bldg01>0 or pay_cont01>0;

INSERT INTO public.srlp_date 
SELECT 
statename, commname, commno, proplocatr, insured, city, state, zipcode, 
notspecsw, nobldgsw, floodprsw, gt100sw, unablidsw, box1sw, box2sw, box3sw, box4sw, histbldsw,
dtloss32, pay_bldg32, pay_cont32,
filler01, pval_ind, ident_dt, occupancy, post_firm, zone, prop_value, building, contents, proplosses, loss_5000, paid, average, tgt_ind, cid
FROM public.srlp
WHERE dtloss32 is not null or pay_bldg32>0 or pay_cont32>0;

alter table public.srlp_date rename column dtloss01 to dtloss;
alter table public.srlp_date rename column pay_bldg01 to pay_bldg;
alter table public.srlp_date rename column pay_cont01 to pay_cont;

alter table public.srlp_date add column year character varying (4);
alter table public.srlp_date add column month character varying (2);
alter table public.srlp_date add column day character varying (2);

update public.srlp_date set year = substr(dtloss, 1, 4) where substr(dtloss, 1, 1) in ('1', '2');
update public.srlp_date set year = 2004 where year is null;

update public.srlp_date set month = substr(dtloss, 5, 2) where substr(dtloss, 5, 2) !='';
update public.srlp_date set month = '12'  where month = '1' or month is null;

update public.srlp_date set day = substr(dtloss, 7, 2) where substr(dtloss, 7, 2) !='';
update public.srlp_date set day = '10'  where day = '1' or day is null;
update public.srlp_date set day = '20'  where day = '2' ;
update public.srlp_date set day = '30'  where day = '3';

alter table public.srlp_date add column dt_of_loss date;
update public.srlp_date
set dt_of_loss = ((year||'-'||month||'-'||day)::date);

select
statename,
cid,
proplocatr,
proplosses,
paid,
prop_value,
max(dt_of_loss) as newest_loss,
min(dt_of_loss) oldest_loss,
max(dt_of_loss) - min(dt_of_loss) as loss_history,
(max(dt_of_loss) - min(dt_of_loss))/proplosses as avg_loss_interval
from public.srlp_date
where occupancy = '1'
group by 1, 2, 3, 4, 5, 6
order by 1, 2, 3;

with s as (
  select sd.commname, sd.proplocatr, year, (sd.pay_bldg + sd.pay_cont)* i.rate as pay 
  from public.srlp_date sd join public.inflation i on (i.from_year = sd.year) 
  where i.to_year = 2015 and sd.cid in (select n.cid from fima.nation n where county = 'SONOMA COUNTY') ) 
select commname, count(distinct proplocatr), count(*) as total_proplosses, sum(pay) 
from s group by 1 order by 1;
      commname       | count | total_proplosses |       sum       
---------------------+-------+------------------+-----------------
 HEALDSBURG, CITY OF |     1 |                6 |    141197.85052
 PETALUMA, CITY OF   |     3 |               14 |  1023349.001941
 SANTA ROSA, CITY OF |     1 |                7 |   157238.699729
 SEBASTOPOL, CITY OF |     2 |                4 |    58641.557758
 SONOMA COUNTY *     |   180 |              977 | 44585184.193181

with s as (
  select sd.commname, sd.proplocatr, year, (sd.pay_bldg + sd.pay_cont)* i.rate as pay 
  from public.srlp_date sd join public.inflation i on (i.from_year = sd.year) 
  where i.to_year = 2015 and sd.cid in (select n.cid from fima.nation n where county = 'SONOMA COUNTY') 
  and dt_of_loss >= '1994-01-01' and dt_of_loss <= '2014-12-31') 
select commname, count(distinct proplocatr), count(*) as total_proplosses, sum(pay) from s group by 1 order by 1;
      commname       | count | total_proplosses |       sum       
---------------------+-------+------------------+-----------------
 PETALUMA, CITY OF   |     3 |                8 |   428698.918357
 SANTA ROSA, CITY OF |     1 |                3 |    70745.837632
 SEBASTOPOL, CITY OF |     2 |                3 |    37016.557758
 SONOMA COUNTY *     |   175 |              562 | 28313174.114357

with s as (
  select sd.commname, sd.proplocatr, year, (sd.pay_bldg + sd.pay_cont)* i.rate as pay 
  from public.srlp_date sd join public.inflation i on (i.from_year = sd.year) 
  where i.to_year = 2015 and sd.cid in (select n.cid from fima.nation n where county = 'SONOMA COUNTY') 
  and dt_of_loss >= '1994-01-01' and dt_of_loss <= '2014-12-31') 
select count(distinct proplocatr), count(*) as total_proplosses, sum(pay) from s;
 count | total_proplosses |       sum       
-------+------------------+-----------------
   181 |              576 | 28849635.428104
