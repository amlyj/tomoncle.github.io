---
title: celery分布式任务队列
date: 2016-11-02 15:20:27
tags: [Python,Distributed,Queue]
categories: Python-celery
---
# celery分布式任务队列
> celery是一种简单、灵活、可靠的分布式系统，可以处理大量的信息，是一个以实时处理为重点，同时支持任务调度的任务队列

# 版本差异使用
## celery (3.1.23) 与 django (1.7.8)
### 安装：
  ```shell
  $ pip install celery==3.1.23
  $ pip install django-celery==3.1.17
  $ pip install django-celery-with-redis==3.0
  ```
### settings.py : 
> 在`INSTALLED_APPS`中添加的`djcelery`是必须的. `kombu.transport.django`则是基于Django的broker
```python
# settings.py

import djcelery

INSTALLED_APPS = (
    '...'
    'djcelery',
    'kombu.transport.django',
    'djangoapp.tasks' # 任务模块
    '...'
)

# 启动后会默认在INSTALLED_APPS寻找tasks.py这个文件,将里面的@task()标记的方法加入任务列表
djcelery.setup_loader()  

# celery模块其他配置参数
CELERY_ENABLE_UTC = False
CELERY_TIMEZONE = 'Asia/Shanghai'

### 以上为公共配置,不管谁做后台都一样
```
<!--more-->
* 使用django内置的服务来作为celery的后台:
  * 配置 settings.py：
    ```python
    BROKER_URL = 'django://'
    ```

* 使用rabbitMQ服务来作为celery的后台:
  * 安装：
    ```shell
    $ apt-get install rabbitmq-server
    $ pip install celery
    $ pip install django-celery
    ```
  * 常见错误：段错误 (核心已转储) ==>遇到这个错误的系统中的python-librabbitmq版本为1.0.3-0ubuntu1
    ```shell
    $ apt-get remove python-librabbitmq
    $ pip install librabbitmq
    ```
  * 配置 settings.py：
    ```python
    #settings　配置使用rabbitmq作为celery的后台
    BROKER_HOST = "localhost"
    BROKER_PORT = 5672
    BROKER_USER = "guest"
    BROKER_PASSWORD = "guest"
    BROKER_VHOST = "/"
    ```
    
* 使用redis服务来作为celery的后台:
  * 安装：
    ```shell
    $ pip install django-celery-with-redis
    $ pip install celery
    $ pip install django-celery
    ```
  * 配置 settings.py：
    ```python
    #settings　配置使用redis来作为celery的后台
    BROKER_URL="redis://localhost:6379/0"
    ```
* settings.py其它配置：
  ```python
  # CELERY_ALWAYS_EAGER = True       #配置该项可以在系统使用celery定义的方法时不用显示打使用xx.delay()来调用
  # CELERYBEAT_SCHEDULER = 'djcelery.schedulers.DatabaseScheduler'

  #broker: 代理
  #backend: 指定保存结果后端

  #可以设置没有返回结果，在任务中加入ignore_result属性 @app.task(ignore_result=True)

  #CELERY_ENABLE_UTC = False 　　# 不使用UTC
  #CELERY_TIMEZONE = 'Asia/Shanghai'
  #CELERY_TASK_RESULT_EXPIRES = 10 　# 任务结果的时效时间
  #CELERYD_LOG_FILE = BASE_DIR + "/logs/celery/celery.log" # log路径
  #CELERYBEAT_LOG_FILE = BASE_DIR + "/logs/celery/beat.log" # beat log路径
  #CELERY_ACCEPT_CONTENT = ['pickle', 'json', 'msgpack', 'yaml'] # 允许的格式

  #CELERY_TASK_SERIALIZER='json'
  #CELERY_RESULT_SERIALIZER='json'
  #CELERY_RESULT_BACKEND='redis://10.0.0.0:6379/0'
  ```

* celery常用命令：
  ```shell
  # 1.启动terminal
  $ python manage.py  runserver 0.0.0.0:19999

  # 2.启动worker:
  $ python manage.py celery worker --loglevel=info

  # 3.Celery会通过celerybeat进程来完成定期任务
  $ python manage.py celery beat

  # 4.后台运行/重启/停止/停止等待
  $ python manage celery multi start/restart/stop/stopwait w1 -A proj -l info
  ```

### 代码编写：
* 目录：
  ```
  tom@aric-ThinkPad-E450:~/djangoapp/djangoapp/tasks$ tree
  .
  ├── __init__.py
  ├── task_a.py
  ├── task_b.py
  └── tasks.py
  ```

* tasks.py
  ```python
  # -*- coding: UTF-8 -*-
  """
  celery启动时会自动扫描tasks.py 这个文件,
  使用时需要导入子模块
  """

  from celery import platforms

  # 导入任务子模块
  from task_a import *
  from task_b import *

  # 开启超级管理员使用模式
  platforms.C_FORCE_ROOT = True
  ```

* tasks_a.py
  ```python
  # -*- coding: UTF-8 -*-
  """
  usage: add.delay(1, 10)

  : function_name.delay(**args)

  """
  import threading
  import time

  import celery

  # 创建task对象
  # 注意：修改task代码时,需要重启celery
  task = celery.task()


  @task
  def add(x, y):
      """
      打印和返回的内容均会在celery启动的终端中进行打印输出
      :param x:
      :param y:
      :return:
      """
      print '%s: begin...' % threading.Thread().getName()
      time.sleep(10)
      print '%s: end...' % threading.Thread().getName()
      return '[[return data:%s,%s]]' % (x, y)

  ```
## celery (4.1.0)

