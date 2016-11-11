set search_path=us,summary,fima,public;

-- 1. annual per capita
drop table us.policy_yearly_2015_llj_pop10;
create table us.policy_yearly_2015_llj_pop10
as select
llj_id,
year,
ljp.pop10 as population,
count,
count/ljp.pop10 as count_capita,
t_premium,
t_premium/ljp.pop10 as t_premium_capita,
t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
t_cov_cont/ljp.pop10 as t_cov_cont_capita,
(t_cov_bldg+t_cov_cont) as t_cov,
(t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
j.income,
j.class,
extract(epoch from (year||'-01-01')::date) as epoch_start,
extract(epoch from (year||'-12-31')::date) as epoch_end,
boundary
from summary.policy_yearly_2015_llj s
--join fima.lljpolicy lj using (llj_id)
--join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_income j using (llj_id)
join fima.lljpolicy_population ljp using (llj_id)
where year>=1994 and year<=2014
order by 1, 2;

alter table us.policy_yearly_2015_llj_pop10 add primary key (llj_id, year);

-- cd Downloads/Time_Manager/US_Annual_#policy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_Annual_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_premiumpolicy_capita.mp4

-- 1.1 annual per capita by jurisdiction

drop table us.policy_yearly_2015_j_pop10;
create table us.policy_yearly_2015_j_pop10 as
select 
jurisdiction_id,
year,
j_pop10 as population,
count,
count/cast(j_pop10 as decimal(18,4)) as count_capita,
t_premium,
t_premium/cast(j_pop10 as decimal(18,4)) as t_premium_capita,
t_cov_bldg/cast(j_pop10 as decimal(18,4)) as t_cov_bldg_capita,
t_cov_cont/cast(j_pop10 as decimal(18,4)) as t_cov_cont_capita,
(t_cov_bldg+t_cov_cont) as t_cov,
(t_cov_bldg + t_cov_cont)/cast(j_pop10 as decimal(18,4)) as t_cov_capita,
j.income,
j.class,
boundary
from summary.policy_yearly_2015_j
join fima.j_income j using (jurisdiction_id)
where year >= 1994 and year <= 2014
order by 1,2;

alter table us.policy_yearly_2015_j_pop10 add primary key (jurisdiction_id, year);



-- 2. monthly new per capita
-- not making yet
drop table us.policy_monthlynew_2015_llj_pop10;
create table us.policy_monthlynew_2015_llj_pop10
as select
llj_id,
effdate,
ljp.pop10 as population,
count/ljp.pop10 as count_capita,
premium/ljp.pop10 as t_premium_capita,
t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
t_cov_cont/ljp.pop10 as t_cov_cont_capita,
(t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
extract(epoch from (effdate + interval '1 day' - interval '1 month') ) as epoch_start,
extract(epoch from (effdate + interval '1 day' ) ) as epoch_end,
lj.boundary
from summary.policy_monthlyeff_2015_llj s
join fima.lljpolicy lj using (llj_id)
--join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id);

-- cd Downloads/Time_Manager/US_monthlynew_#policy_capita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Monthly_new_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_monthlynew_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Monthly_new_premiumpolicy_capita.mp4


-- 3 MONTHLY effective policy per capita, at the end of each month
-- for Time_manager monthly interval purpose, epoch_start is at the first day of a month, epoch_end is the same as effdate which is the last day of a month
drop table us.policy_monthlyeff_2015_llj_pop10;
create table us.policy_monthlyeff_2015_llj_pop10 as
select
 llj_id,
 effdate,
 ljp.pop10 as population,
 count/ljp.pop10 as count_capita,
 premium/ljp.pop10 as premium_capita,
 t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
 t_cov_cont/ljp.pop10 as t_cov_cont_capita,
 (t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
 extract(epoch from (effdate + interval '1 day' - interval '1 month') ) as epoch_start,
 extract(epoch from (effdate ) ) as epoch_end,
 lj.boundary
from summary.policy_monthlyeff_2015_llj s
join fima.lljpolicy lj using (llj_id)
--join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id)
where count > 1.0e-010;

select effdate, max(count_capita) from us.policy_monthlyeff_2015_llj_pop10 group by 1 order by 2 desc limit 5;

  effdate   |        max         
------------+--------------------
 2002-08-31 | 85000.000000000000
 2002-09-30 | 85000.000000000000
 2002-07-31 | 85000.000000000000
 2002-10-31 | 80000.000000000000
 2002-11-30 | 75000.000000000000

select effdate, max(premium_capita) from us.policy_monthlyeff_2015_llj_pop10 group by 1 order by 2 desc limit 5;

  effdate   |       max        
------------+------------------
 2002-07-31 |         52003068
 2002-09-30 | 48558938.5000001
 2002-08-31 |         48467295
 2002-04-30 |       45246676.5
 2002-05-31 |       45246676.5

      
-- cd Downloads/Time_Manager/US_monthly_effective_#policy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_monthly_effective_#policy_capita_slow.mp4
-- mencoder mf://*.png -mf w=640:h=480:fps=2:type=png -ovc copy -oac copy -o US_monthly_effective_#policy_capita.mp4
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o US_monthly_effective_#policy_capita_fast.mp4
-- mencoder mf://*.png -mf w=640:h=480:fps=10:type=png -ovc copy -oac copy -o US_monthly_effective_#policy_capita_faster.mp4

-- 4 daily effective policy per capita
-- not making yet
drop table us.policy_dailyeff_2015_llj_pop10;
create table us.policy_dailyeff_2015_llj_pop10 as
select
 llj_id,
 effdate,
 ljp.pop10 as population,
 count/ljp.pop10 as count_capita,
 t_premium/ljp.pop10 as t_premium_capita,
 t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
 t_cov_cont/ljp.pop10 as t_cov_cont_capita,
 (t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
 extract(epoch from effdate) as epoch_start,
 extract(epoch from (effdate + interval '1 day') ) as epoch_end,
 lj.boundary
from summary.policy_dailyeff_2015_llj s
join fima.lljpolicy lj using (llj_id)
--join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id)
where count > 1.0e-010;;
      
      
