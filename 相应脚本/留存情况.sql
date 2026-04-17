select * from user_behavior where dates is null;
delete from user_behavior where dates is null;# 已经删除过了

-- 构造“用户-日期”去重表 ,只关注用户是否活跃
select user_id,dates
from temp_behavior
group by user_id,dates;

-- 自关联
select * from
    (select user_id,dates
     from temp_behavior
     group by user_id,dates
    ) a
            ,(select user_id,dates
              from temp_behavior
              group by user_id,dates
    ) b
where a.user_id=b.user_id;

select * from user_behavior limit 500;

-- 筛选
select * from
    (select user_id,dates
     from temp_behavior
     group by user_id,dates
    ) a
            ,(select user_id,dates
              from temp_behavior
              group by user_id,dates
    ) b
where a.user_id=b.user_id and a.dates<b.dates;

-- 留存数
select a.dates
     ,count(if(datediff(b.dates,a.dates)=0,b.user_id,null)) retention_0
     ,count(if(datediff(b.dates,a.dates)=1,b.user_id,null)) retention_1
     ,count(if(datediff(b.dates,a.dates)=3,b.user_id,null)) retention_3
from

(select user_id,dates
    from temp_behavior
    group by user_id,dates
) a,
(select user_id,dates
    from temp_behavior
    group by user_id,dates
) b
where a.user_id=b.user_id and a.dates<=b.dates
group by a.dates

-- 留存率
select a.dates
     ,count(if(datediff(b.dates,a.dates)=1,b.user_id,null))/count(if(datediff(b.dates,a.dates)=0,b.user_id,null)) retention_1
from
    (select user_id,dates
     from temp_behavior
     group by user_id,dates
    ) a
   ,(select user_id,dates
     from temp_behavior
     group by user_id,dates
) b
where a.user_id=b.user_id and a.dates<=b.dates
group by a.dates

-- 保存结果
create table retention_rate(
    dates char(10),
    retrention_1 float
);

insert into retention_rate
select a.dates
     ,count(if(datediff(b.dates,a.dates)=1,b.user_id,null))/count(if(datediff(b.dates,a.dates)=0,b.user_id,null)) retention_1
from
    (select user_id,dates
     from user_behavior
     group by user_id,dates
    ) a
   ,(select user_id,dates
     from user_behavior
     group by user_id,dates
) b
where a.user_id=b.user_id and a.dates<=b.dates
group by a.dates

select * from retention_rate

-- 跳失率
-- 跳失用户  -- 88
select count(*)
from
    (
        select user_id from user_behavior
        group by user_id
        having count(behavior)=1
    ) a


select sum(pv) from pv_uv_puv;