---
title: Kubernetes-High-Availability
date: 2017-07-08 14:30:21
tags: [HA]
categories: kubernetes
# password: tomoncler
---

# Kubernetes Cluster HA
> apiserver do cluster,controller-manager and scheduler do HA
> servers(centos7):192.168.137.145~147

<!-- more -->
## 环境准备工作

    #关闭防火墙
    systemctl stop firewalld && systemctl disable firewalld

    #关闭selinux
    setenforce 0 
    #编辑/etc/selinux/config  SELINUX=disabled
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

## 软件安装
    
    yum -y install etcd kubernetes 

## ETCD集群
获取etcd集群token
    
    #获取etcd集群token (https://discovery.etcd.io/3254bffbbd2a7814f401733088931eaa)
    curl https://discovery.etcd.io/new?size=3

etcd配置/etc/etcd/etcd.conf
    
    # [member]
    ETCD_NAME=etcd2
    ETCD_DATA_DIR="/var/lib/etcd/etcd2.etcd"
    #ETCD_WAL_DIR=""
    #ETCD_SNAPSHOT_COUNT="10000"
    #ETCD_HEARTBEAT_INTERVAL="100"
    #ETCD_ELECTION_TIMEOUT="1000"
    ETCD_LISTEN_PEER_URLS="http://192.168.137.146:2380"
    ETCD_LISTEN_CLIENT_URLS="http://localhost:2379,http://192.168.137.146:2379"
    #ETCD_MAX_SNAPSHOTS="5"
    #ETCD_MAX_WALS="5"
    #ETCD_CORS=""
    #
    #[cluster]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.137.146:2380"
    # if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
    #ETCD_INITIAL_CLUSTER="default=http://localhost:2380"
    #ETCD_INITIAL_CLUSTER_STATE="new"
    #ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_ADVERTISE_CLIENT_URLS="http://192.168.137.146:2379"
    ETCD_DISCOVERY="https://discovery.etcd.io/3254bffbbd2a7814f401733088931eaa"
    #ETCD_DISCOVERY_SRV=""
    #ETCD_DISCOVERY_FALLBACK="proxy"
    #ETCD_DISCOVERY_PROXY=""
    #ETCD_STRICT_RECONFIG_CHECK="false"
    #
    #[proxy]
    #ETCD_PROXY="off"
    #ETCD_PROXY_FAILURE_WAIT="5000"
    #ETCD_PROXY_REFRESH_INTERVAL="30000"
    #ETCD_PROXY_DIAL_TIMEOUT="1000"
    #ETCD_PROXY_WRITE_TIMEOUT="5000"
    #ETCD_PROXY_READ_TIMEOUT="0"
    #
    #[security]
    #ETCD_CERT_FILE=""
    #ETCD_KEY_FILE=""
    #ETCD_CLIENT_CERT_AUTH="false"
    #ETCD_TRUSTED_CA_FILE=""
    #ETCD_PEER_CERT_FILE=""
    #ETCD_PEER_KEY_FILE=""
    #ETCD_PEER_CLIENT_CERT_AUTH="false"
    #ETCD_PEER_TRUSTED_CA_FILE=""
    #
    #[logging]
    #ETCD_DEBUG="false"
    # examples for -log-package-levels etcdserver=WARNING,security=DEBUG
    #ETCD_LOG_PACKAGE_LEVELS=""

## kubernetes 
配置/etc/kubernetes

### apiServer

    ###
    # kubernetes system config
    #
    # The following values are used to configure the kube-apiserver
    #

    # The address on the local server to listen to.
    KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"

    # The port on the local server to listen on.
    # KUBE_API_PORT="--port=8080"

    # Port minions listen on
    # KUBELET_PORT="--kubelet-port=10250"

    # Comma separated list of nodes in the etcd cluster
    KUBE_ETCD_SERVERS="--etcd-servers=http://127.0.0.1:2379,http:192.168.1.146:2379,http://192.168.1.147:2379"

    # Address range to use for services
    KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"

    # default admission control policies
    KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"

    # Add your own!
    KUBE_API_ARGS=""

### config

    ###
    # kubernetes system config
    #
    # The following values are used to configure various aspects of all
    # kubernetes services, including
    #
    #   kube-apiserver.service
    #   kube-controller-manager.service
    #   kube-scheduler.service
    #   kubelet.service
    #   kube-proxy.service
    # logging to stderr means we get it in the systemd journal
    KUBE_LOGTOSTDERR="--logtostderr=true"

    # journal message level, 0 is debug
    KUBE_LOG_LEVEL="--v=0"

    # Should this cluster be allowed to run privileged docker containers
    KUBE_ALLOW_PRIV="--allow-privileged=false"

    # How the controller-manager, scheduler, and proxy find the apiserver，配置参数(本机ip:8080)
    KUBE_MASTER="--master=http://192.168.137.145:8080"


### controller-manager

    ###
    # The following values are used to configure the kubernetes controller-manager

    # defaults from config and apiserver should be adequate

    # Add your own!
    # --leader-elect=true 表示etcd 服务master选举，只有选举为leader的节点才会执行操作，即做controller-manager高可用
    # --master=127.0.0.1:8080  参数可以不指定，默认使用本地的8080端口
    KUBE_CONTROLLER_MANAGER_ARGS="--master=127.0.0.1:8080 --v=2 --leader-elect=true 1>>/var/log/kube-controller-manager.log 2>&1"

### scheduler

    ###
    # kubernetes scheduler config

    # default config should be adequate

    # Add your own!
    # 参数配置见controller-manager
    KUBE_SCHEDULER_ARGS="--master=127.0.0.1:8080 --v=2 --leader-elect=true"

### kubelet

    ###
    # kubernetes kubelet (minion) config

    # The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)
    KUBELET_ADDRESS="--address=0.0.0.0"

    # The port for the info server to serve on
    # KUBELET_PORT="--port=10250"

    # You may leave this blank to use the actual hostname
    KUBELET_HOSTNAME="--hostname-override=node01"

    # location of the api-server cluster api main 集群入口
    KUBELET_API_SERVER="--api-servers=http://vip:port"

    # pod infrastructure container
    KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"

    # Add your own!
    KUBELET_ARGS=""
                                                                                                                                                       

* `apiServer`可以使用`keepalived`做集群，或者使用`nginx`做集群都可以。
* 网络里使用flannel或者其他网络管理组件都可以。

