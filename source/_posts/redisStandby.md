---
title: redis主从模式配置
date: 2016-10-02 17:38:28
tags: [redis]
categories: Redis
---
# redis主备环境搭建master-slave 
以下我在本地一台服务器搭建一个master–slave 主从复制结构
### 服务安装目录结构
```shell
[root@node1 redis]# tree
.
├── bin
│   ├── redis-benchmark
│   ├── redis-check-aof
│   ├── redis-check-rdb
│   ├── redis-cli
│   ├── redis-sentinel -> redis-server
│   └── redis-server
├── master.conf
├── node.conf
├── redis.conf.bak
└── sentinel.conf

1 directory, 10 files
```
<!--more-->

### 文件内容对比

##### Master与备份文件内容对比
```shell
[root@node1 redis]# diff redis.conf.bak master.conf 
128c128
< daemonize no
---
> daemonize yes
247c247
< dir ./
---
> dir /opt/redis-db/master/
593c593
< appendonly no
---
> appendonly yes
```

##### master与node文件内容对比
```shell
[root@node1 redis]# diff master.conf node.conf 
84c84
< port 6379
---
> port 6380
150c150
< pidfile /var/run/redis_6379.pid
---
> pidfile /var/run/redis_6380.pid
247c247
< dir /opt/redis-db/master/
---
> dir /opt/redis-db/node/
265c265
< # slaveof <masterip> <masterport>
---
> slaveof 127.0.0.1 6379
[root@node1 redis]# 

```

### 服务启动
```shell
[root@node1 redis]# bin/redis-server master.conf
[root@node1 redis]# bin/redis-server node.conf
[root@node1 redis]# ps -ef|grep redis
root       5895      1  0 09:47 ?        00:00:00 bin/redis-server 127.0.0.1:6379
root       5899      1  0 09:47 ?        00:00:00 bin/redis-server 127.0.0.1:6380
root       5977   5922  0 09:56 pts/2    00:00:00 grep --color=auto redis
[root@node1 redis]# 

```

### 主从切换

###### master 读写
```shell
[root@node1 redis]# ./bin/redis-cli
127.0.0.1:6379> set name aric
OK
127.0.0.1:6379> get name
"aric"
127.0.0.1:6379> set age 21
OK
127.0.0.1:6379> get age
"21"
127.0.0.1:6380> quit
[root@node1 redis]#
```
##### node 只读
```shell
[root@node1 redis]# ./bin/redis-cli -p 6380
127.0.0.1:6380> keys *
1) "name"
2) "age"
127.0.0.1:6380> get name
"aric"
127.0.0.1:6380> set name abc
(error) READONLY You can't write against a read only slave.
127.0.0.1:6380> quit
[root@node1 redis]#
```
##### 杀死Master节点
```shell
[root@node1 redis]# bin/redis-cli shutdown
[root@node1 redis]#
[root@node1 redis]# bin/redis-cli
Could not connect to Redis at 127.0.0.1:6379: Connection refused
Could not connect to Redis at 127.0.0.1:6379: Connection refused
not connected> quit
[root@node1 redis]# ps -ef|grep redis
root       5899      1  0 09:47 ?        00:00:01 bin/redis-server 127.0.0.1:6380
root       5984   5667  0 10:00 pts/1    00:00:00 grep --color=auto redis
[root@node1 redis]# 
```

##### 设置node节点升级为Master
```shell
[root@node1 redis]# bin/redis-cli -p 6380 slaveof NO ONE
OK
[root@node1 redis]# bin/redis-cli -p 6380
127.0.0.1:6380> keys *
1) "name"
2) "age"
127.0.0.1:6380> get name
"aric"
127.0.0.1:6380> set name abc
OK
127.0.0.1:6380> get name
"abc"
127.0.0.1:6380> quit
[root@node1 redis]# 
```
##### 启动Master，使Master节点恢复，并更新最新数据
```shell
[root@node1 redis]# cp /opt/redis-db/node/appendonly.aof /opt/redis-db/master/
cp：是否覆盖"/opt/redis-db/master/appendonly.aof"？ y
[root@node1 redis]# cp /opt/redis-db/node/dump.rdb /opt/redis-db/master/
cp：是否覆盖"/opt/redis-db/master/dump.rdb"？ y
[root@node1 redis]# ./bin/redis-server master.conf 
[root@node1 redis]# ./bin/redis-cli -p 6380 slaveof 127.0.0.1 6379
OK
[root@node1 redis]# ./bin/redis-cli
127.0.0.1:6379> keys *
1) "name"
2) "age"
127.0.0.1:6379> get name
"abc"
127.0.0.1:6379> quit
[root@node1 redis]# ./bin/redis-cli -p 6380
127.0.0.1:6380> get name
"abc"
127.0.0.1:6380> set name tom
(error) READONLY You can't write against a read only slave.
127.0.0.1:6380> quit
[root@node1 redis]# 
```
### 自动切换可以使用keepalived实现或redis自带的哨兵机制

# 哨兵机制
监控redis系统的运行状态
* 监控主节点数据库和从节点数据库是否正常运行
* 主节点服务器出现故障，可以将从节点服务器自动转换为主服务器

### 实现步骤
* 1.copy sentinel.conf 文件到“从服务器”安装目录
* 2.修改sentinel.conf以下内容：
```shell
# Example sentinel.conf

port 26379
dir "/tmp"

sentinel monitor master 127.0.0.1 6379 1
sentinel down-after-milliseconds master 1500
sentinel failover-timeout master 10000
```
 
* 3.启动服务
```shell
[root@node1 redis]# ./bin/redis-server sentinel.conf --sentinel &
```

* 查看哨兵信息
 * 哨兵服务: redis-cli -p 26379
 * 查看信息: info Sentinel
 
### 主从切换
##### 杀死主节点服务
    [root@node1 redis]# kill -9 6166

##### 查看sentinel服务日志
```shell
6194:X 22 Oct 10:59:50.055 # +sdown master node1 127.0.0.1 6379
6194:X 22 Oct 10:59:50.055 # +odown master node1 127.0.0.1 6379 #quorum 1/1
6194:X 22 Oct 10:59:50.055 # +new-epoch 1
6194:X 22 Oct 10:59:50.055 # +try-failover master node1 127.0.0.1 6379
6194:X 22 Oct 10:59:50.057 # +vote-for-leader 0567c93f4760c410c77ed1717b808219c90d2258 1
6194:X 22 Oct 10:59:50.058 # +elected-leader master node1 127.0.0.1 6379
6194:X 22 Oct 10:59:50.058 # +failover-state-select-slave master node1 127.0.0.1 6379
6194:X 22 Oct 10:59:50.159 # +selected-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ node1 127.0.0.1 6379
6194:X 22 Oct 10:59:50.159 * +failover-state-send-slaveof-noone slave 127.0.0.1:6380 127.0.0.1 6380 @ node1 127.0.0.1 6379
6194:X 22 Oct 10:59:50.226 * +failover-state-wait-promotion slave 127.0.0.1:6380 127.0.0.1 6380 @ node1 127.0.0.1 6379
6194:X 22 Oct 10:59:51.103 # +promoted-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ node1 127.0.0.1 6379
6194:X 22 Oct 10:59:51.104 # +failover-state-reconf-slaves master node1 127.0.0.1 6379
6194:X 22 Oct 10:59:51.153 # +failover-end master node1 127.0.0.1 6379
6194:X 22 Oct 10:59:51.153 # +switch-master node1 127.0.0.1 6379 127.0.0.1 6380
6194:X 22 Oct 10:59:51.153 * +slave slave 127.0.0.1:6379 127.0.0.1 6379 @ node1 127.0.0.1 6380
6194:X 22 Oct 10:59:52.696 # +sdown slave 127.0.0.1:6379 127.0.0.1 6379 @ node1 127.0.0.1 6380

```

##### 登录从节点服务器
```shell
[root@node1 redis]# ./bin/redis-cli -p 6380
127.0.0.1:6380> info
# Server
...
# Replication
role:master
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
..

127.0.0.1:6380> 
127.0.0.1:6380> get name
"abc"
127.0.0.1:6380> set name aric
OK
127.0.0.1:6380> get name
"aric"
127.0.0.1:6380> quit
[root@node1 redis]# 

```
##### 恢复主节点，自动切换为从服务器
```
[root@node1 redis]# ./bin/redis-server master.conf 
[root@node1 redis]# 
[root@node1 redis]# ./bin/redis-cli
127.0.0.1:6379> info
# Server
...
# Replication
role:slave
master_host:127.0.0.1
master_port:6380
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:4542
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
...
127.0.0.1:6379> get name
"aric"
127.0.0.1:6379> 
127.0.0.1:6379> set name 123
(error) READONLY You can't write against a read only slave.
127.0.0.1:6379> 

```
###### 配置完成

