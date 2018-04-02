---
title: redis动态添加删除节点
date: 2016-10-05 17:39:04
tags: [redis,cluster,node]
categories: Redis
---
# redis动态添加、删除节点

## 添加节点
* 添加节点命令： **`./redis/bin/redis-trib.rb add-node 新节点ip:端口 已知节点ip:端口`** 
```bash
[root@node1 redis-cluster]#./redis/bin/redis-trib.rb add-node 192.168.137.147:7007 192.168.137.147:7001
```
  
* 添加slave节点（方式1） :
```bash
[root@node1 redis-cluster]#./redis/bin/redis-trib.rb add-node  --slave --master-id 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7008 192.168.137.147:7007

```
* 添加slave节点（方式2） ：
```bash
[root@node1 redis-cluster]#./redis/bin/redis-trib.rb add-node 192.168.137.147:7008 192.168.137.147:7007
[root@node1 redis-cluster]#
[root@node1 redis-cluster]# ./redis/bin/redis-cli -c -h 192.168.137.147 -p 7008
192.168.137.147:7008> CLUSTER REPLICATE 813befe6b157312120c27c0d29573b84e79245a7
OK
192.168.137.147:7008>
```
<!--more-->  
##### 新增端口为7007的节点
* 1.查看当前节点信息
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-cli -c -h 192.168.137.147 -p 7001
192.168.137.147:7001> 
192.168.137.147:7001> 
192.168.137.147:7001> 
192.168.137.147:7001> CLUSTER NODES
b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001 myself,master - 0 0 8 connected 0-5627 10923-11088
4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003 master - 0 1486387997595 3 connected 11089-16383
e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006 slave 4af3d70ace7038c82b65104c983c18e8a047fb12 0 1486387999637 6 connected
b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005 slave 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 0 1486388001678 5 connected
8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004 slave b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 0 1486387998614 8 connected
4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002 master - 0 1486388000659 2 connected 5628-10922
192.168.137.147:7001> 

```
* 2.启动端口为7007的节点,配置文件与其他6个节点配置方式一致
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-server 7007/redis.conf 
[root@node1 redis-cluster]# 

```
* 3.执行添加操作
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb add-node 192.168.137.147:7007 192.168.137.147:7001
>>> Adding node 192.168.137.147:7007 to cluster 192.168.137.147:7001
>>> Performing Cluster Check (using node 192.168.137.147:7001)
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:1-5627,10923-11088 (5793 slots) master
   1 additional replica(s)
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:0,11089-16383 (5296 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5628-10922 (5295 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.137.147:7007 to make it join the cluster.
[OK] New node added correctly.
[root@node1 redis-cluster]# 

```

* 4.检测是否添加成功
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb check 192.168.137.147:7007
>>> Performing Cluster Check (using node 192.168.137.147:7007)
M: 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7007
   slots: (0 slots) master
   0 additional replica(s)
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:0,11089-16383 (5296 slots) master
   1 additional replica(s)
M: 0d4c4a73991ce0f759adbf51a1453b7fa088fbae 192.168.137.147:7008
   slots: (0 slots) master
   0 additional replica(s)
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:1-5627,10923-11088 (5793 slots) master
   1 additional replica(s)
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5628-10922 (5295 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
[root@node1 redis-cluster]# 

```
 >>可以看到已经添加成功，并且为Master，id为813befe6b157312120c27c0d29573b84e79245a7 ，但是没有分配数据槽
 
 * 5.从其他主节点分配数据槽
 **`这里我从7001节点分配200个数据槽（注意删除的时候，要写199，因为从0开始）`**
 ```bash
 [root@node1 redis-cluster]#  ./redis/bin/redis-trib.rb reshard 192.168.137.147:7001
>>> Performing Cluster Check (using node 192.168.137.147:7001)
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:1-5627,10923-11088 (5793 slots) master
   1 additional replica(s)
M: 0d4c4a73991ce0f759adbf51a1453b7fa088fbae 192.168.137.147:7008
   slots: (0 slots) master
   0 additional replica(s)
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:0,11089-16383 (5296 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5628-10922 (5295 slots) master
   1 additional replica(s)
M: 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7007
   slots: (0 slots) master
   0 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 200 (这个是要从7001节点分配的槽数目)
What is the receiving node ID? 813befe6b157312120c27c0d29573b84e79245a7 (这个是新增节点的id)
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1:all
...
...
Do you want to proceed with the proposed reshard plan (yes/no)? yes
...
...
 
 ```
 * 6.检测数据槽是否分配成功
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb check 192.168.137.147:7007
>>> Performing Cluster Check (using node 192.168.137.147:7007)
M: 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7007
   slots:0-71,5628-5691,11089-11151 (199 slots) master
   0 additional replica(s)
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:11152-16383 (5232 slots) master
   1 additional replica(s)
M: 0d4c4a73991ce0f759adbf51a1453b7fa088fbae 192.168.137.147:7008
   slots: (0 slots) master
   0 additional replica(s)
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:72-5627,10923-11088 (5722 slots) master
   1 additional replica(s)
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5692-10922 (5231 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
[root@node1 redis-cluster]# 

```
* 7.为7007节点添加从节点7008 (7008配置文件与集群文件配置方式一致)
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-server 7008/redis.conf 
[root@node1 redis-cluster]# 
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb add-node  --slave --master-id 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7008 192.168.137.147:7007
>>> Adding node 192.168.137.147:7008 to cluster 192.168.137.147:7007
>>> Performing Cluster Check (using node 192.168.137.147:7007)
M: 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7007
   slots:0-71,5628-5691,11089-11151 (199 slots) master
   0 additional replica(s)
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:11152-16383 (5232 slots) master
   1 additional replica(s)
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:72-5627,10923-11088 (5722 slots) master
   1 additional replica(s)
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5692-10922 (5231 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.137.147:7008 to make it join the cluster.
Waiting for the cluster to join.
>>> Configure node as replica of 192.168.137.147:7007.
[OK] New node added correctly.
[root@node1 redis-cluster]# 

```
 
* 8.检测集群节点信息
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb check 192.168.137.147:7007
>>> Performing Cluster Check (using node 192.168.137.147:7007)
M: 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7007
   slots:0-71,5628-5691,11089-11151 (199 slots) master
   1 additional replica(s)
S: 4149ffd8c52696e76ecd77bc86e4dc861c1786cf 192.168.137.147:7008
   slots: (0 slots) slave
   replicates 813befe6b157312120c27c0d29573b84e79245a7
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:11152-16383 (5232 slots) master
   1 additional replica(s)
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:72-5627,10923-11088 (5722 slots) master
   1 additional replica(s)
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5692-10922 (5231 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
[root@node1 redis-cluster]# 

```

## 删除节点
* 命令 **`./redis/bin/redis-trib.rb del-node 新节点ip:端口 新增节点id`** 
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb del-node 192.168.137.147:7008 e6194194f91fdb8a35c59265131dfc92b054391b
```
  
### 删除端口为7007的主节点及7008的从节点
##### 删除7008从节点
* 1.删除节点
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb del-node 192.168.137.147:7008 4149ffd8c52696e76ecd77bc86e4dc861c1786cf
>>> Removing node 4149ffd8c52696e76ecd77bc86e4dc861c1786cf from cluster 192.168.137.147:7008
>>> Sending CLUSTER FORGET messages to the cluster...
>>> SHUTDOWN the node.
[root@node1 redis-cluster]# 
```
* 2.检测节点
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb check 192.168.137.147:7007
>>> Performing Cluster Check (using node 192.168.137.147:7007)
M: 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7007
   slots:0-71,5628-5691,11089-11151 (199 slots) master
   0 additional replica(s)
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:11152-16383 (5232 slots) master
   1 additional replica(s)
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:72-5627,10923-11088 (5722 slots) master
   1 additional replica(s)
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5692-10922 (5231 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
[root@node1 redis-cluster]# 
```

##### 删除7007主节点
* 1.移除7007主节点数据槽
```bash
[root@node1 redis-cluster]# ./redis/bin/redis-trib.rb reshard 192.168.137.147:7007
>>> Performing Cluster Check (using node 192.168.137.147:7007)
M: 813befe6b157312120c27c0d29573b84e79245a7 192.168.137.147:7007
   slots:0-71,5628-5691,11089-11151 (199 slots) master
   0 additional replica(s)
M: 4af3d70ace7038c82b65104c983c18e8a047fb12 192.168.137.147:7003
   slots:11152-16383 (5232 slots) master
   1 additional replica(s)
S: 8d368f763314c8ea237cd467e650eef99f6aeb38 192.168.137.147:7004
   slots: (0 slots) slave
   replicates b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8
M: b8c7a04b84b06a5b3f4a529c0cc32c0c915ebcc8 192.168.137.147:7001
   slots:72-5627,10923-11088 (5722 slots) master
   1 additional replica(s)
S: b7544d7ff478b46cfb4d89c781ce8079332dcedf 192.168.137.147:7005
   slots: (0 slots) slave
   replicates 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60
M: 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 192.168.137.147:7002
   slots:5692-10922 (5231 slots) master
   1 additional replica(s)
S: e88d24aa120b37751a1aaafbd66db799833587c1 192.168.137.147:7006
   slots: (0 slots) slave
   replicates 4af3d70ace7038c82b65104c983c18e8a047fb12
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 199 (7007节点释放的槽数量)
What is the receiving node ID? 4543836ee8a65a4b30b0f226a0dd6a5c3c04ab60 （接受数据槽的目标节点id,这里释放到7002节点）
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1:813befe6b157312120c27c0d29573b84e79245a7 （7007节点的id）
Source node #2:done
...
...
Do you want to proceed with the proposed reshard plan (yes/no)? yes
...
...

```

* 2.删除7007节点 （**重复删除7008从节点步骤即可**）



# cussess !!

