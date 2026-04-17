-- 最近购买时间
select user_id
     ,max(dates) '最近购买时间'
from temp_behavior
where behavior_type='buy'
group by user_id
order by 2 desc;

-- 购买次数
select user_id
     ,count(user_id) '购买次数'
from temp_behavior
where behavior_type='buy'
group by user_id
order by 2 desc;

-- 统一
select user_id
     ,count(user_id) '购买次数'
     ,max(dates) '最近购买时间'
from user_behavior
where behavior_type='buy'
group by user_id
order by 2 desc,3 desc;

-- 存储
drop table if exists rfm_model;
create table rfm_model(
                          user_id int,
                          frequency int,
                          recent char(10)
);

insert into rfm_model
select user_id
     ,count(user_id) '购买次数'
     ,max(dates) '最近购买时间'
from user_behavior
where behavior_type='buy'
group by user_id
order by 2 desc,3 desc;

-- 根据购买次数对用户进行分层
alter table rfm_model add column fscore int;

update rfm_model
set fscore = case
                 when frequency between 100 and 262 then 5
                 when frequency between 50 and 99 then 4
                 when frequency between 20 and 49 then 3
                 when frequency between 5 and 20 then 2
                 else 1
    end

-- 根据最近购买时间对用户进行分层
alter table rfm_model add column rscore int;

update rfm_model
set rscore = case
                 when recent = '2017-12-03' then 5
                 when recent in ('2017-12-01','2017-12-02') then 4
                 when recent in ('2017-11-29','2017-11-30') then 3
                 when recent in ('2017-11-27','2017-11-28') then 2
                 else 1
    end

select * from rfm_model

-- 分层
set @f_avg=null;
set @r_avg=null;
select avg(fscore) into @f_avg from rfm_model;
select avg(rscore) into @r_avg from rfm_model;

select *
     ,(case
           when fscore>@f_avg and rscore>@r_avg then '价值用户'
           when fscore>@f_avg and rscore<@r_avg then '保持用户'
           when fscore<@f_avg and rscore>@r_avg then '发展用户'
           when fscore<@f_avg and rscore<@r_avg then '挽留用户'
    end) class
from rfm_model

-- 插入
alter table rfm_model add column class varchar(40);
update rfm_model
set class = case
                when fscore>@f_avg and rscore>@r_avg then '价值用户'
                when fscore>@f_avg and rscore<@r_avg then '保持用户'
                when fscore<@f_avg and rscore>@r_avg then '发展用户'
                when fscore<@f_avg and rscore<@r_avg then '挽留用户'
    end


-- 统计各分区用户数
select class,count(user_id) from rfm_model
group by class
