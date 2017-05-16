
RANCHO SANTA MARGARITA, CITY OF |     59 |  18206000 |   20563
SAN FRANCISCO, CITY AND COUNTY OF|    132 |  36638900 |   78098

(need to update in the imported csv)

drop table ca.ca_policy_20170331;
create table ca.ca_policy_20170331 as
select
n.cid,
p.*,
j.boundary,
j.j_pop10 as population
from ca.policydata p
left outer join fima.nation n on (p.community = n.community_name)
left outer join fima.jurisdictions j on (n.cid = j.j_cid)
where n.state = 'CA' and j.j_statefp10 = '06';

alter table ca.ca_policy_20170331 add primary key (cid);
select * from ca.policydata p where p.community not in (select c.community from ca.ca_policy_20170331 c where c.community is not null);
           community            | policy | insurance | premium 
--------------------------------+--------+-----------+---------
 RL MONTE, CITY OF              |      6 |   1645000 |    2110
 AGUA CALIENTE BAND OF CAHUILLA |    159 |  40740400 |   79261

(need to manually add to the table)

RL MONTE, CITY OF: cid = '060658'
(should be EL MONTE, CITY OF)
AGUA CALIENTE BAND OF CAHUILLA: cid = '060763' use '060245'
(060763 AGUA CALIENTE BAND OF CAHUILLA INDIANS TRIBE, RIVERSIDE COUNTY, 
 USE THE RIVERSIDE COUNTY [060245] FIRM AND USE THE CITIES OF CATHEDRAL CITY [060704] AND PALM SPRINGS [060257] FIRMS.)

update ca.ca_policy_20170331 c
set boundary = (
select j.boundary 
from fima.jurisdictions j
where j.j_cid = '060658')
where c.cid =  '060658';

update ca.ca_policy_20170331 c
set population = (
select j. j_pop10 
from fima.jurisdictions j
where j.j_cid = '060658')
where c.cid =  '060658';

update ca.ca_policy_20170331 c
set boundary = (
select j.boundary 
from fima.jurisdictions j
where j.j_cid = '060245')
where c.cid =  '060763';

update ca.ca_policy_20170331 c
set population = (
select j. j_pop10 
from fima.jurisdictions j
where j.j_cid = '060245')
where c.cid =  '060763';

select 
n.county,
sum(policy) as policy,
sum(insurance) as insurance,
sum(premium) as premium
from ca.ca_policy_20170331 c
join fima.nation n using (cid)
group by 1
order by 1;
