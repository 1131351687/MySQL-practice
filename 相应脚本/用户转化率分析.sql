-- 统计各类行为用户数
select behavior
,count(DISTINCT  user_id)user_num
from temp_behavior
group by behavior
order by behavior desc;

desc temp_behavior;

-- 存储
create table behavior_user_num(
    behavior varchar(5),
    user_num int
);

insert into behavior_user_num
select behavior
     ,count(DISTINCT  user_id)user_num
from user_behavior
group by behavior
order by behavior desc;

select * from behavior_user_num;

-- 统计各类行为的数量
select behavior
,count(*) user_num
from temp_behavior
group by behavior
order by behavior desc;

-- 存储
create table behavior_num(
    behavior varchar(5),
    behavior_count_num int
);

insert into behavior_num
select behavior
     ,count(*) user_num
from user_behavior
group by behavior
order by behavior desc;

select * from behavior_num

-- 购买率
select
    count(distinct case when behavior='buy' then user_id end) * 1.0 /
    count(distinct case when behavior='pv' then user_id end)
        as buy_rate
from temp_behavior;

-- 收藏加购率
select
    count(distinct b.user_id) * 1.0 / count(distinct c.user_id) as cart_to_buy_rate
from
    (select distinct user_id from temp_behavior where behavior='cart') c
        left join
    (select distinct user_id from temp_behavior where behavior='buy') b
    on c.user_id = b.user_id;