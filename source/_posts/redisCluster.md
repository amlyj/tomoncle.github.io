---
title: redis集群搭建
date: 2016-09-02 17:38:07
tags: [redis,cluster]
categories: Redis
---
# redis集群 3.2
> 这里我使用3.2版本测试. 

## 1.新建redis集群文件夹

    mkdir -p  /opt/redis-cluster
    cd /opt/redis-cluster

## 2.新建6个节点文件7001-7006 和redis文件夹
    
    mkdir 7001 7002 7003 7004 7005 7006 redis


## 3.copy解压后的redis文件到redis文件夹
    
    tar xvf redis3.2.bin.tar 
    cp -r redis /opt/redis-cluster

## 4.copy redis文件夹下的redis.conf到6个节点文件下

    cp ./redis/redis.conf ./700*

## 5.修改6个节点的redis.conf 文件
<!--more-->
```
+----+---------------------------------------+--------------------------------------+---------------------------------------------
|数量| 　　　默认参数          　　　　　　　　　　|     　修改参数                         ｜     描述
+----+---------------------------------------+--------------------------------------+---------------------------------------------
|  1 | bind 127.0.0.1         　　　　　　　　　| bind 192.168.1.1                     | 绑定的网卡地址
|  2*| port 6379                             | port　700*                           | 端口
|  3 | daemonize no           　　　　　　　　　| daemonize yes                        | 开启守护进程模式运行
|  4 | pidfile /var/run/redis_6379.pid       | pidfile /var/run/redis_700*.pid      | 伪集群下要指定不同的守护进程pid 
|  5 | dir ./                 　　　　　　　　　| dir /opt/redis-cluster/700*/         | 指定不同的数据文件目录
|  6*| appendonly no                         | appendonly yes                       | 开启aof持久化
|  7*| # cluster-enabled yes  　　　　　　　　　| cluster-enabled yes                  | 开启集群模式
|  8*| # cluster-config-file nodes-6379.conf | cluster-config-file nodes-700*.conf  | 集群配置文件，伪集群下要指定不同文件地址，会自动生成.
|  9*| # cluster-node-timeout 15000          | cluster-node-timeout 15000           | 节点互连超时时间
| 10#| databases 16           　　　　　　　　　| databases 1                          | 可用数据库，默认存在０号服务器，建议设置一个 
| 11#| # cluster-migration-barrier 1         | cluster-migration-barrier 1          | master可以拥有的最小slave数量
| 12#| # cluster-require-full-coverage yes   | cluster-require-full-coverage yes    | 集群若存在key space没有覆盖，禁止写入 
+----+---------------------------------------+--------------------------------------+---------------------------------------------
*表示集群模式最小配置，＃表示建议配置，可以不配置
```

    vim redis.conf
    [root@node1 redis-cluster]# diff redis/redis.conf 7001/redis.conf 
    61c61
    < bind 127.0.0.1
    ---
    > bind 192.168.137.147
    84c84
    < port 6379
    ---
    > port 7001
    128c128
    < daemonize no
    ---
    > daemonize yes
    247c247
    < dir ./
    ---
    > dir /opt/redis-cluster/7001/
    593c593
    < appendonly no
    ---
    > appendonly yes
    721c721
    < # cluster-enabled yes
    ---
    > cluster-enabled yes
    729c729
    < # cluster-config-file nodes-6379.conf
    ---
    > cluster-config-file nodes-7001.conf
    735c735
    < # cluster-node-timeout 15000
    ---
    > cluster-node-timeout 5000
    [root@node1 redis-cluster]# 

    #vim 替换快捷键  :%s/7001/7002/g



## 6.安装ruby依赖包

    yum -y install ruby rubygems 
    gem install redis


## 7.分别启动redis 6个节点

    [root@node1 redis-cluster]# 
    [root@node1 redis-cluster]# ./redis/bin/redis-server ./7001/redis.conf 
    [root@node1 redis-cluster]# ./redis/bin/redis-server ./7002/redis.conf 
    [root@node1 redis-cluster]# ./redis/bin/redis-server ./7003/redis.conf 
    [root@node1 redis-cluster]# ./redis/bin/redis-server ./7004/redis.conf 
    [root@node1 redis-cluster]# ./redis/bin/redis-server ./7005/redis.conf 
    [root@node1 redis-cluster]# ./redis/bin/redis-server ./7006/redis.conf 
    [root@node1 redis-cluster]# 
    [root@node1 redis-cluster]# ps -ef|grep redis
    root       2474      1  0 23:11 ?        00:00:00 ./redis/bin/redis-server 192.168.137.147:7001 [cluster]
    root       2478      1  0 23:11 ?        00:00:00 ./redis/bin/redis-server 192.168.137.147:7002 [cluster]
    root       2482      1  0 23:12 ?        00:00:00 ./redis/bin/redis-server 192.168.137.147:7003 [cluster]
    root       2486      1  0 23:12 ?        00:00:00 ./redis/bin/redis-server 192.168.137.147:7004 [cluster]
    root       2490      1  0 23:12 ?        00:00:00 ./redis/bin/redis-server 192.168.137.147:7005 [cluster]
    root       2494      1  0 23:12 ?        00:00:00 ./redis/bin/redis-server 192.168.137.147:7006 [cluster]
    root       2515   2370  0 23:12 pts/1    00:00:00 grep --color=auto redis
    [root@node1 redis-cluster]# 

## 8.使用redis-trib.rb 创建集群

    [root@node1 redis-cluster]# 
    [root@node1 redis-cluster]# ./redis/bin/redis-trib.rb create --replicas 1 \
    > 192.168.137.147:7001 192.168.137.147:7002 192.168.137.147:7003 \
    > 192.168.137.147:7004 192.168.137.147:7005 192.168.137.147:7006
    >>> Creating cluster
    >>> Performing hash slots allocation on 6 nodes...
    Using 3 masters:
    192.168.137.147:7001
    192.168.137.147:7002
    192.168.137.147:7003
    Adding replica 192.168.137.147:7004 to 192.168.137.147:7001
    Adding replica 192.168.137.147:7005 to 192.168.137.147:7002
    Adding replica 192.168.137.147:7006 to 192.168.137.147:7003
    M: 7ea4b261762457810bd5f7d50388a5e399e4ee19 192.168.137.147:7001
       slots:0-5460 (5461 slots) master
    M: 4c928118bfd6cc950636f2950048ca557ccf6e8e 192.168.137.147:7002
       slots:5461-10922 (5462 slots) master
    M: d3c10b1f6b44f32530536e9d0bc810928d1a3c21 192.168.137.147:7003
       slots:10923-16383 (5461 slots) master
    S: 7154bff37824c68916aff613cc1f13722cff6a7e 192.168.137.147:7004
       replicates 7ea4b261762457810bd5f7d50388a5e399e4ee19
    S: b1c170a509cf6ad8393560ca54810f8ebc2652d8 192.168.137.147:7005
       replicates 4c928118bfd6cc950636f2950048ca557ccf6e8e
    S: 2d243d04267ee61069249cb792441f42c5ea3438 192.168.137.147:7006
       replicates d3c10b1f6b44f32530536e9d0bc810928d1a3c21
    Can I set the above configuration? (type 'yes' to accept): yes
    >>> Nodes configuration updated
    >>> Assign a different config epoch to each node
    >>> Sending CLUSTER MEET messages to join the cluster
    Waiting for the cluster to join......
    >>> Performing Cluster Check (using node 192.168.137.147:7001)
    M: 7ea4b261762457810bd5f7d50388a5e399e4ee19 192.168.137.147:7001
       slots:0-5460 (5461 slots) master
    M: 4c928118bfd6cc950636f2950048ca557ccf6e8e 192.168.137.147:7002
       slots:5461-10922 (5462 slots) master
    M: d3c10b1f6b44f32530536e9d0bc810928d1a3c21 192.168.137.147:7003
       slots:10923-16383 (5461 slots) master
    M: 7154bff37824c68916aff613cc1f13722cff6a7e 192.168.137.147:7004
       slots: (0 slots) master
       replicates 7ea4b261762457810bd5f7d50388a5e399e4ee19
    M: b1c170a509cf6ad8393560ca54810f8ebc2652d8 192.168.137.147:7005
       slots: (0 slots) master
       replicates 4c928118bfd6cc950636f2950048ca557ccf6e8e
    M: 2d243d04267ee61069249cb792441f42c5ea3438 192.168.137.147:7006
       slots: (0 slots) master
       replicates d3c10b1f6b44f32530536e9d0bc810928d1a3c21
    [OK] All nodes agree about slots configuration.
    >>> Check for open slots...
    >>> Check slots coverage...
    [OK] All 16384 slots covered.
    [root@node1 redis-cluster]# 

## 9.集群验证 -c 表示集群模式
##### 客户端登录

    [root@node1 redis-cluster]# ./redis/bin/redis-cli -c -h 192.168.137.147 -p 7001

##### 查看当前节点信息

    192.168.137.147:7001> info
    # Server
    redis_version:3.2.3
    ...
    lru_clock:582158
    executable:/opt/redis-cluster/./redis/bin/redis-server
    config_file:/opt/redis-cluster/./7001/redis.conf
    ...

    # Replication
    role:master
    connected_slaves:1
    slave0:ip=192.168.137.147,port=7004,state=online,offset=393,lag=0
    master_repl_offset:393
    repl_backlog_active:1
    repl_backlog_size:1048576
    repl_backlog_first_byte_offset:2
    repl_backlog_histlen:392

    # CPU
    used_cpu_sys:0.47
    used_cpu_user:0.30
    used_cpu_sys_children:0.00
    used_cpu_user_children:0.00

    # Cluster
    cluster_enabled:1

    # Keyspace

##### 查看集群信息

    192.168.137.147:7001> cluster info
    cluster_state:ok
    cluster_slots_assigned:16384
    cluster_slots_ok:16384
    cluster_slots_pfail:0
    cluster_slots_fail:0
    cluster_known_nodes:6
    cluster_size:3
    cluster_current_epoch:6
    cluster_my_epoch:1
    cluster_stats_messages_sent:851
    cluster_stats_messages_received:851


##### 查看node节点信息

    192.168.137.147:7001> cluster nodes
    b1c170a509cf6ad8393560ca54810f8ebc2652d8 192.168.137.147:7005 slave 4c928118bfd6cc950636f2950048ca557ccf6e8e 0 1476977272444 5 connected
    2d243d04267ee61069249cb792441f42c5ea3438 192.168.137.147:7006 slave d3c10b1f6b44f32530536e9d0bc810928d1a3c21 0 1476977268902 6 connected
    7ea4b261762457810bd5f7d50388a5e399e4ee19 192.168.137.147:7001 myself,master - 0 0 1 connected 0-5460
    d3c10b1f6b44f32530536e9d0bc810928d1a3c21 192.168.137.147:7003 master - 0 1476977269407 3 connected 10923-16383
    7154bff37824c68916aff613cc1f13722cff6a7e 192.168.137.147:7004 slave 7ea4b261762457810bd5f7d50388a5e399e4ee19 0 1476977271434 4 connected
    4c928118bfd6cc950636f2950048ca557ccf6e8e 192.168.137.147:7002 master - 0 1476977270417 2 connected 5461-10922
    192.168.137.147:7001> 

