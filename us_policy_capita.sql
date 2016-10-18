set search_path=us,summary,fima,public;

drop table us.claims_yearly_llj_pop10;
create table us.claims_yearly_llj_pop10
as select
llj_id,
year,
ljp.pop10 as population,
count/ljp.pop10 as count_capita,
pay_bldg/ljp.pop10 as pay_bldg_capita,
pay_cont/ljp.pop10 as pay_cont_capita,
(pay_bldg+pay_cont)/ljp.pop10 as pay_capita,
t_dmg_bldg/ljp.pop10 as t_dmg_bldg_capita,
t_dmg_cont/ljp.pop10 as t_dmg_cont_capita,
(t_dmg_bldg+t_dmg_cont)/ljp.pop10 as t_dmg_capita,
extract(epoch from (year||'-01-01')::date) as epoch_start ,
extract(epoch from (year||'-12-31')::date) as epoch_end,
lj.boundary
from summary.claims_yearly_2015_llj s
join fima.llj lj using (llj_id)
join fima.jurisdictions j using (jurisdiction_id)
join fima.llj_population ljp using (llj_id);

-- cd Downloads/Time_Manager/US_yearly_#claims_capita

-- mencoder mf://*.png -mf w=480:h=640:fps=1:type=png -ovc copy -oac copy -o US_Annual_claims_number_capita.mp4

-- cd Downloads/Time_Manager/US_yearly_payclaims_capita

-- mencoder mf://*.png -mf w=640:h=480:fps=1:type=png -ovc copy -oac copy -o US_Annual_claims_payments_capita.mp4



drop table us.claims_monthly_2015_llj_pop10;
create table us.claims_monthly_2015_llj_pop10
as select
llj_id,
year,
month,
ljp.pop10 as population,
count/ljp.pop10 as count_capita,
pay_bldg/ljp.pop10 as pay_bldg_capita,
pay_cont/ljp.pop10 as pay_cont_capita,
(pay_bldg+pay_cont)/ljp.pop10 as pay_capita,
t_dmg_bldg/ljp.pop10 as t_dmg_bldg_capita,
t_dmg_cont/ljp.pop10 as t_dmg_cont_capita,
(t_dmg_bldg+t_dmg_cont)/ljp.pop10 as t_dmg_capita,
extract(epoch from (year||'-'||CAST(month AS VARCHAR(2))||'-01')::date) as epoch_start,
extract(epoch from ((year||'-'||CAST(month AS VARCHAR(2))||'-01')::date + interval '1 month' - interval '1 day') ) as epoch_end,
extract(epoch from '2015-03-31'::date) as accu_epoch_end,
lj.boundary
from summary.claims_monthly_summary_2015_llj s
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

drop table us.claims_accum_monthly_2015_llj_pop10;
create table us.claims_accum_monthly_2015_llj_pop10
as select
llj_id,
year,
month,
sum(count_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_count_capita,
sum(pay_bldg_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_pay_bldg_capita,
sum(pay_cont_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_pay_cont_capita,
sum(pay_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_pay_capita,
sum(t_dmg_bldg_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_t_dmg_bldg_capita,
sum(t_dmg_cont_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_t_dmg_cont_capita,
sum(t_dmg_capita) OVER(PARTITION BY llj_id ORDER BY year, month) AS accu_t_dmg_capita,
epoch_start,
epoch_end,
accu_epoch_end,
boundary
from us.claims_monthly_2015_llj_pop10;
