---
title: MQ安装整理
date: 2016-05-02 17:40:29
tags: [activemq,rabbitmq,mq]
categories: MQ
---
# activeMQ

### 安装-[下载](http://activemq.apache.org/download-archives.html)
* 1.安装jdk，需要jdk1.7以上版本
* 2.解压缩activeMQ的压缩包 : `tar -zxvf apache-activemq-*-bin.tar.gz`
* 3.进入`bin`目录`启动`和`停止`:
   * 启动 ：`./activemq start`
   * 停止 ：`./activemq stop`

### 访问后台管理:
* 地址：`http://localhost:8161/admin`
* 用户名：`admin`
* 密码：`admin`


### 端口说明：
`ActiveMQ`默认采用`61616`端口提供`JMS`服务，使用`8161`端口提供管理控制台服务

<!--more-->

# rabbitMQ

## 安装
#### ubuntu14.04
* 安装`rabbitMQ`, 默认安装依赖的`erlang`(使用`erl`命令来检测): `sudo apt-get install rabbitmq-server`
* 检测安装目录: `whereis rabbitmq`
* 进入安装目录，开启web查看工具：`cd /usr/lib/rabbitmq/bin && rabbitmq-plugins enable rabbitmq_management`
* 重启服务：`rabbitmqctl stop & rabbitmq-server start`
* 测试访问：`curl http://127.0.0.1:15672/`

