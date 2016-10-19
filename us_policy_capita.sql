set search_path=us,summary,fima,public;

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

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Annual_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_Annual_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_premiumpolicy_capita.mp4



drop table us.policy_monthlynew_2015_llj_pop10;
create table us.policy_monthlynew_2015_llj_pop10
as select
llj_id,
year,
month,
year - 1 as syear,
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
join fima.lljpolicy_population ljp using (llj_id) where llj_id <= 1000;

-- cd Downloads/Time_Manager/US_monthlynew_#policy_capita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Monthly_new_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_monthlynew_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Monthly_new_premiumpolicy_capita.mp4


drop table us.policy_monthlyeff_2015_llj_pop10;
create table us.policy_monthlyeff_2015_llj_pop10
as select
llj_id,
year,
syear,
month,
sum(count_capita) OVER(PARTITION BY llj_id ORDER BY year, month) - sum(count_capita) OVER(PARTITION BY llj_id ORDER BY syear, month) AS eff_count_capita,
sum(t_premium_capita) OVER(PARTITION BY llj_id ORDER BY year, month) - sum(t_premium_capita) OVER(PARTITION BY llj_id ORDER BY syear, month) AS eff_t_premium_capita,
sum(t_cov_bldg_capita) OVER(PARTITION BY llj_id ORDER BY year, month) - sum(t_cov_bldg_capita) OVER(PARTITION BY llj_id ORDER BY syear, month) AS eff_t_cov_bldg_capita,
sum(t_cov_cont_capita) OVER(PARTITION BY llj_id ORDER BY year, month) - sum(t_cov_cont_capita) OVER(PARTITION BY llj_id ORDER BY syear, month) AS eff_t_cov_cont_capita,
sum(t_cov_capita) OVER(PARTITION BY llj_id ORDER BY year, month) - sum(t_cov_capita) OVER(PARTITION BY llj_id ORDER BY syear, month) AS eff_t_cov_capita,
epoch_start,
epoch_end,
boundary
from us.policy_monthlynew_2015_llj_pop10
where year>=1994 and year<=2014;

-- cd Downloads/Time_Manager/US_monthlyeff_#policy_capita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Monthly_effective_#policy_capita.mp4

-- cd Downloads/Time_Manager/US_monthlyeff_premiumpolicy_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Monthly_effective_premiumpolicy_capita.mp4

with t as (
  select
  year,
  month
  from us.policy_monthlynew_2015_llj_pop10
  group by 1,2
  order by 1,2),
s as (
  select
  llj_id,
  year as year,
  month,
  sum(count_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS scount
  from us.policy_monthlynew_2015_llj_pop10),
e as (select
  llj_id,
  year + 1 as year,
  month,
  sum(count_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS ecount
  from us.policy_monthlynew_2015_llj_pop10)
select 
j.llj_id,
t.year AS year,
t.month AS month,
s.scount,
e.ecount,
s.scount - e.ecount as count_eff
from us.policy_monthlynew_2015_llj_pop10 j 
full join t using(year, month)
full join s using(llj_id, year, month)
full join e using(llj_id, year, month)
where llj_id = 1 order by year, month;
      
     
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
