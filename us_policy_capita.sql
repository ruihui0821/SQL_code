set search_path=us,summary,fima,public;

-- 1. annual per capita
drop table us.policy_yearly_llj_pop10;
create table us.policy_yearly_llj_pop10
as select
llj_id,
year,
ljp.pop10 as population,
count/ljp.pop10 as count_capita,
t_premium/ljp.pop10 as t_premium_capita,
t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
t_cov_cont/ljp.pop10 as t_cov_cont_capita,
(t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
extract(epoch from (year||'-01-01')::date) as epoch_start,
extract(epoch from (year||'-12-31')::date) as epoch_end,
lj.boundary
from summary.policy_yearly_2015_llj s
join fima.lljpolicy lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id)
where year>=1994 and year<=2014;

-- cd Downloads/Time_Manager/US_Annual_#policy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_Annual_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_premiumpolicy_capita.mp4

-- 2. monthly new per capita
-- not making yet
drop table us.policy_monthlynew_2015_llj_pop10;
create table us.policy_monthlynew_2015_llj_pop10
as select
llj_id,
year,
month,
ljp.pop10 as population,
count/ljp.pop10 as count_capita,
t_premium/ljp.pop10 as t_premium_capita,
t_cov_bldg/ljp.pop10 as t_cov_bldg_capita,
t_cov_cont/ljp.pop10 as t_cov_cont_capita,
(t_cov_bldg+t_cov_cont)/ljp.pop10 as t_cov_capita,
extract(epoch from (year||'-'||CAST(month AS VARCHAR(2))||'-01')::date) as epoch_start,
extract(epoch from ((year||'-'||CAST(month AS VARCHAR(2))||'-01')::date + interval '1 month' - interval '1 day') ) as epoch_end,
lj.boundary
from summary.policy_monthly_summary_2015_llj s
join fima.lljpolicy lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
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
join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id)
where llj_id is not null and count > 1.0e-010;

select effdate, max(count_capita) from us.policy_monthlyeff_2015_llj_pop10 group by 1 order by 2 desc limit 5;

  effdate   |        max         
------------+--------------------
 1997-10-31 | 60000.000000000000
 1998-02-28 | 60000.000000000000
 1997-11-30 | 60000.000000000000
 1997-12-31 | 60000.000000000000
 1997-09-30 | 60000.000000000000

select effdate, max(premium_capita) from us.policy_monthlyeff_2015_llj_pop10 group by 1 order by 2 desc limit 5;

  effdate   |       max        
------------+------------------
 2002-09-30 |         33610747
 2002-08-31 | 33519103.5000001
 2002-04-30 |       33451829.5
 2002-05-31 |       33451829.5
 2002-07-31 | 33430198.0000001

      
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
join fima.jurisdictions j using (jurisdiction_id)
join fima.lljpolicy_population ljp using (llj_id)
where llj_id is not null and count > 1.0e-010;;
      
      
