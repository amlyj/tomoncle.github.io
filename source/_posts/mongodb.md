---
title: mongodb使用整理
date: 2016-06-06 17:11:08
tags: [Mongodb,DB]
categories: Mongodb
---

# mongodb

## 安装

* 1.数据库 [下载地址](https://www.mongodb.com/download-center?jmp=nav#community)　

* 2.解压安装包到 `/usr/local/mongodb/`
  * `sudo mkdir /usr/local/mongodb`
  * `sudo tar zxvf 软件包 -C /usr/local/mongodb/`

* 3.创建数据库`文件夹data` ,`日志文件logs`
  * `sudo mkdir /usr/local/mongodb/data`
  * `sudo touch /usr/local/mongodb/logs`

* 4.创建启动脚本 `start.sh`
<!--more-->
```shell
#! /bin/bash

echo "warning:start mongodb"
sleep 1
echo "............."
echo "............."
echo "............."
workdir=/usr/local/mongodb/mongodb-3.2.11
datapath=/usr/local/mongodb/data/
logpath=/usr/local/mongodb/logs

sudo "$workdir"/bin/mongod --dbpath="$datapath" --logpath="$logpath" --logappend  --port=27017 --fork
sleep 2
echo -e "\n mongodb start success!!!"
```

* 5.创建mongodb客户端软链接,直接使用mongo命令 :
`sudo ln -s /usr/local/mongodb/mongodb-3.2.11/bin/mongo /usr/local/bin/`


## 参数说明
```txt          
--dbpath=/usr/lcoal/mongodb/data/             mongodb数据文件存储路径	 
--logpath=/var/log/mongodb/mongodb.log        mongod的日志路径	                   
--logappend=true                              日志使用追加代替覆盖	               
--bind_ip=10.10.10.10                         绑定的IP	                          
--port=27107                                  绑定的端口	                         
--journal=true                                write操作首先写入“日记”，是一个数据安全的设置，具体参考官方文档。	   
--fork=true                                   后台运行           　　　　　　　　　　
-f ./mongo.conf                               启动配置文件，可以将以上参数写入配置文件，通过mongod -f ./mongo.conf启动

```

## 基本概念
  
    SQL术语/概念　　　 MongoDB概念　　      意义
    database　　　　　 database　　　　　　 数据库
    table　　　　　　　collection　　　　 　数据库表/集合
    row　　　　　　　　document　　　　　　 数据记录行/文档
    column　　　　　　 field　　　　　　　　数据字段/域
    index　　　　　　　index　　　　　　　  索引
    primarykey　　　　 primary key　　　　  主键,MongoDB自动将_id字段设置为主键
    
    
## 连接
 
    连接本地数据库服务器，端口是默认的。
    mongodb://localhost
    使用用户名fred，密码foobar登录localhost的admin数据库。
    mongodb://fred:foobar@localhost
    使用用户名fred，密码foobar登录localhost的baz数据库。
    mongodb://fred:foobar@localhost/baz
    连接 replica pair, 服务器1为example1.com服务器2为example2。
    mongodb://example1.com:27017,example2.com:27017
    连接 replica set 三台服务器 (端口 27017, 27018, 和27019):
    mongodb://localhost,localhost:27018,localhost:27019
    连接 replica set 三台服务器, 写入操作应用在主服务器 并且分布查询到从服务器。
    mongodb://host1,host2,host3/?slaveOk=true
    直接连接第一个服务器，无论是replica set一部分或者主服务器或者从服务器。
    mongodb://host1,host2,host3/?connect=direct;slaveOk=true
    当你的连接服务器有优先级，还需要列出所有服务器，你可以使用上述连接方式。
    安全模式连接到localhost:
    mongodb://localhost/?safe=true
    以安全模式连接到replica set，并且等待至少两个复制服务器成功写入，超时时间设置为2秒。
    mongodb://host1,host2,host3/?safe=true;w=2;wtimeoutMS=2000

## 数据库
###### mongodb默认使用test数据库

    查询数据库列表：
    ＞show dbs
    创建或切换数据库：（ 注：刚刚创建的数据库使用show dbs命令无法看到，需要插入数据才会显示 db.aric.insert({"name":"king-aric"})）
    ＞use aric
    查看当前数据库：
    ＞db
    删除数据库：（首先切换到要删除的数据，use db_name,使用　show dbs查看是否删除成功）
    ＞ db.dropDatabase()
    查看当前数据库集合（表）
    ＞show tables 或　show collections
    创建集合（表）：当插入文档的时候，会自动创建相应的集合
    ＞db.collection_or_table_name.insert({})
    删除集合（表）：
    ＞db.collection_or_table_name.drop()
    
## 文档

    插入：
    ＞db.aric.save({"k":2})　　插入或更新（当指定文档id时，会覆盖当前文档的数据）
    ＞db.aric.insert({"k":2})　插入
    更新：将k为２的对象改为k=2xxxx
    ＞db.aric.update({"k":2},{$set:{"k":"2xxx"}},{multi:true}) 更新多条，
    ＞db.aric.update({"k":2},{$set:{"k":"2xxx"}})　更新一条
    删除：删除k=2xxx的数据
    ＞db.aric.remove({"k":"2xxx"},1) 删除一条
    ＞db.aric.remove({"k":"2xxx"})　删除多条
    ＞db.aric.remove({})　删除全部
    查询：
    ＞db.aric.find()
    ＞db.aric.find().pretty() 格式化输出
    ＞db.aric.findOne() 返回一个文档
    复杂查询：SQL : 'where age>50 AND (name = 'aric' OR title = 'MongoDB')'
    ＞db.aric.find({"age": {$gt:50}, $or: [{"name": "aric"},{"title": "MongoDB"}]}).pretty()
    

# mongodb常见异常

### child process failed, exited with error number 1
> about to fork child process, waiting until server is ready for connections.
forked process: 2340
ERROR: child process failed, exited with error number 1

解决办法：
* 1.删除 /usr/local/mongodb/data/mongo.lock
* 2.执行以下脚本清除数据库
  * 查找清除目录：`/usr/local/bin/mongod --repair`
  * 清除指定目录：`/usr/local/bin/mongod --repair --dbpath=/usr/local/mongodb/data/`

