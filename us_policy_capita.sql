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
join fima.llj lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
join fima.llj_population ljp using (llj_id)
where year>=1994 and year<=2014;

-- cd Downloads/Time_Manager/US_yearly_#claims_capita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Annual_claims_number_capita.mp4

-- cd Downloads/Time_Manager/US_yearly_payclaims_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_claims_payments_capita.mp4



drop table us.policy_monthly_2015_llj_pop10;
create table us.policy_monthly_2015_llj_pop10
as select
llj_id,
year,
year + 1 as endyear,
month,
month - 1 as endmonth,
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
join fima.llj lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
join fima.llj_population ljp using (llj_id);

-- cd Downloads/Time_Manager/US_monthly_#claims_kcapita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Monthly_claims_number_kcapita.mp4

-- cd Downloads/Time_Manager/US_monthly_payclaims_kcapita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Monthly_claims_payments_kcapita.mp4

-- cd Downloads/Time_Manager/US_accumulative_monthly_#claims_capita

-- Creating a Motion PNG (MPNG) file from all the PNG files in the current directory:
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc copy -oac copy -o US_Accumulative_Monthly_#claims_capita.mp4

-- Creating an uncompressed file from all the PNG files in the current directory:
-- mencoder mf://*.png -mf w=640:h=480:fps=5:type=png -ovc raw -oac copy -o US_Accumulative_Monthly_#claims_capita.mp4
-- convert to high quality but large size
-- mencoder US_Accumulative_Monthly_#claims_capita.avi -o US_Accumulative_Monthly_#claims_capita.wmv -of lavf -oac lavc -ovc lavc \ -lavcopts vcodec=wmv1:vbitrate=1500:acodec=wmav1 (not work)
-- mencoder "mf://*.png" -mf fps=5 -o US_Accumulative_Monthly_#claims_capita.wmv -ovc lavc -lavcopts vcodec=wmv2

drop table us.policy_effmonthly_2015_llj_pop10;
create table us.policy_effmonthly_2015_llj_pop10
as select
llj_id,
year,
endyear,
month,
endmonth,
sum(count_capita) OVER(PARTITION BY llj_id ORDER BY endyear, endmonth) - sum(count_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_count_capita,
sum(t_premium_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_t_premium_capita,
sum(t_cov_bldg_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_t_cov_bldg_capita,
sum(t_cov_cont_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_t_cov_cont_capita,
sum(t_cov_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_t_cov_capita,
epoch_start,
epoch_end,
boundary
from us.policy_monthly_2015_llj_pop10;
