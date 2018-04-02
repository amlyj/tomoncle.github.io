---
title: mysql常用命令
date: 2016-05-02 17:16:08
tags: [Mysql]
categories: Mysql
---
# mysql安装
> 整理一些常用的mysql命令与一些示例.

# 初始化配置
#### 初始化root密码：`mysqladmin -u root password 'root'`
#### 修改root密码
```
@>mysql -u root -p
@>密码
MySQL>update mysql.user set password=password('新密码') where User="admin" and Host="localhost";
MySQL>flush privileges;
```
#### 开启远程访问
```
MySQL>use mysql; 
MySQL>update user set host = '%' where user = 'root';
MySQL>flush privileges;
```
#### 异常：ERROR 1062 (23000): Duplicate entry '%-root' for key 'PRIMARY'
使用命令 `select host from user where user='root';`查看是否存在了**host='%'**,如果存在，直接命令：`flush privileges;`

<!--more-->
# linux常用命令
操作命令要以分号结束

### 登陆
    mysql -uroot -p
### 终端清屏
    mysql> system clear

## 创建：
##### 创建数据库：
```shell
mysql -h localhost -P 3306 -uroot -p123456 <<EOF
  CREATE DATABASE db_name;
  alter database db_name character set utf8;
  GRANT ALL PRIVILEGES ON db_name.* TO 'user_name'@'localhost' IDENTIFIED BY 'password';
  GRANT ALL PRIVILEGES ON db_name.* TO 'user_name'@'%' IDENTIFIED BY 'password';
  FLUSH PRIVILEGES;
  exit
EOF
```

## 查看
##### 查看数据库：
    show databases;

##### 进入数据库：
    use test;
    
##### 查看数据库表：

    show tables;

    select table_name from information_schema.tables where table_schema='king-aric';
   
##### 查看表结构：
    desc tablename;

##### 查看表数据：
    select * from tablename;
    select * from tablename\G
     
##### 生成删除test数据库的所有表的结果集
```sql
mysql> 
mysql> SELECT concat('DROP TABLE IF EXISTS ', table_name, ';')
    -> FROM information_schema.tables
    -> WHERE table_schema = 'test';
+--------------------------------------------------+
| concat('DROP TABLE IF EXISTS ', table_name, ';') |
+--------------------------------------------------+
| DROP TABLE IF EXISTS celery_taskmeta;            |
| DROP TABLE IF EXISTS celery_tasksetmeta;         |
| DROP TABLE IF EXISTS cloud_center;               |
| DROP TABLE IF EXISTS cloud_version;              |
| DROP TABLE IF EXISTS cron_model;                 |
+--------------------------------------------------+
5 rows in set (0.07 sec)

mysql> DROP TABLE IF EXISTS celery_taskmeta; 
```
##### 生成清空test数据库所有表数据结果集
```sql
SELECT concat('TRUNCATE TABLE ', table_name, ';') FROM information_schema.tables WHERE table_schema = 'test';
```

## mysql备份
### 只导出表结构
##### 导出整个数据库结构（不包含数据）
```sql
root@aric-ThinkPad-E450:/# mysqldump -h localhost -uroot -p -d database > dump.sql
```
##### 导出单个数据表结构（不包含数据）
```sql
root@aric-ThinkPad-E450:/# mysqldump -h localhost -uroot -p  -d database table > dump.sql
```
### 只导出表数据
##### 导出整个数据库数据
```sql
root@aric-ThinkPad-E450:/# mysqldump -h localhost -uroot -p  -t database > dump.sql
```
##### 导出数据库一个表数据
```sql
root@aric-ThinkPad-E450:/# mysqldump -h localhost -uroot -p  -t database table > table_dump.sql
```

### 导出结构+数据
##### 导出整个数据库结构和数据
```sql
root@aric-ThinkPad-E450:/# mysqldump -h localhost -uroot -p database > dump.sql
```
##### 导出单个数据表结构和数据
```sql
root@aric-ThinkPad-E450:/# mysqldump -h localhost -uroot -p  database table > dump.sql
```

## mysql脚本
### 保存生成＂删除test数据库＂的脚本到文件
```sql
root@aric-ThinkPad-E450:/# 
root@aric-ThinkPad-E450:/# mysql -p  -N -s information_schema -e "SELECT CONCAT('delete from ',TABLE_NAME,';') FROM TABLES WHERE TABLE_SCHEMA='test'" > /opt/temp.sql;
Enter password: 
root@aric-ThinkPad-E450:/# cat /opt/temp.sql 
```

### 执行sql脚本[参数　"-D数据库"]到test数据库
```sql
root@aric-ThinkPad-E450:/# mysql -p -Dtest < /opt/temp.sql 
```

### 执行sql语句
```sql
root@aric-ThinkPad-E450:/# mysql -p -e "select * from test.users"
```
