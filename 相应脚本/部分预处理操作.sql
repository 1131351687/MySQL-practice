use taobao;
desc user_behavior;
select * from user_behavior limit 500;
SELECT count(1) from user_behavior;

alter table user_behavior add id int first;
select * from user_behavior limit 500;
alter table user_behavior modify id int primary key auto_increment;
