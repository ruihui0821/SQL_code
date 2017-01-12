-- adding the t_prop_val (val_main + val_app) and the val_cont data from the original claims table to the paidclaims table
alter table public.paidclaims add column t_prop_val numeric(10,0);
alter table public.paidclaims add column val_cont integer;

update public.paidclaims p
set t_prop_val = (
  select c.t_prop_val 
  from public.claims c
  where p.gid = c.gid)
where exists(
  select c.t_prop_val 
  from public.claims c
  where p.gid = c.gid);

update public.paidclaims p
set val_cont = (
  select c.val_cont 
  from public.claims c
  where p.gid = c.gid)
where exists(
  select c.val_cont 
  from public.claims c
  where p.gid = c.gid);
  
  
  select waterdepth, pay_bldg, pay_cont, pay_bldg+pay_cont as pay, t_prop_val, val_cont, t_prop_val+val_cont as value from claims where pay_bldg >0 and pay_cont >0;
