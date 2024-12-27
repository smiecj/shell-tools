# shell tools

脚本工具，用于更快速地安装开发环境、中间件、命令行工具等

## gcc, glibc, cmake 和 make

```
# gcc
make gcc

# glibc
make glibc

# cmake
make cmake

# make
make make
```

## zsh

安装 zsh

```
make zsh
```

## llvm & clang

install clang

```
make clang
```

## ninja

install ninja

```
make ninja
```

## python

安装 conda & python3

```
make python
```

只安装 conda

```
make conda
```

## nodejs

安装 nodejs

```
make nodejs
```

## [java](https://github.com/adoptium/jdk)

安装 java (1.8 & 17), maven, gradle, ant

```
make java
```

安装指定版本 jdk

```shell
# 安装 jdk 21
# 注意: 为了在通常情况，不与系统 java 冲突，写入 /etc/profile 的环境变量是 JDK_HOME 而不是 JAVA_HOME
jdk_version=21 make jdk
```

安装 maven

```
make maven
```

## golang

安装 golang

```
make golang
```

## php

安装 php

```
make php
```

## rust

安装 rust

```
make rust
```

## [git](https://github.com/git/git)

安装 git

```
make git
```

## [jq](https://github.com/jqlang/jq)

安装 jq: json 解析工具

```
make

## [code server](https://github.com/coder/code-server)

```shell
make codeserver
```

## [prometheus](https://github.com/prometheus/prometheus)

```shell
# 安装 prometheus, alertmanager, pushgateway 和 node exporter
make monitor-prometheus
prometheus_jobs=pushgateway__localhost:9091::node_exporter__localhost:9100 prometheus_alertmanager_address=localhost:3002 make monitor-prometheus

# 仅安装 prometheus
make prometheus
```

## [grafana](https://github.com/grafana/grafana)

```shell
# 安装 grafana
make grafana
```

## [httpd](https://github.com/apache/httpd)

```shell
# 安装 httpd
make httpd
```

## [mysql](https://github.com/mysql/mysql-server)

关于 mysql 多说两句: 最快的安装方式，当然是从 mysql 官方下载 rpm/deb 直接安装，但是[官方](https://dev.mysql.com/downloads/mysql/)提供的安装包中，8.0 之前的只有 amd 架构，强迫症让我必须把 5.7 在 arm 的安装也实现。怎么实现呢，就只能从源码安装了

```shell
# 准备: 安装 rpcgen
make rpcgen

# 编译安装 mysql 5.7.44
mysql_skip_abi_check=true mysql_version=5.7.44 make mysql

# 编译安装 mysql 8.0.39
mysql_version=8.0.39 make mysql

# 指定密码和数据存储路径
mysql_version=8.0.39 mysql_data_dir=/opt/data/mysql mysql_root_password=rootMySQLPwd1 make mysql

# 初始化数据路径和root密码
# 注意: root 密码在第一次 init 才会修改
mysqlinit

# 启动
mysqlstart

# 连接 mysql
mysqlconnect
```

## [jupyter](https://github.com/jupyterhub/jupyterhub)

```shell
# 安装 jupyterhub 和 jupyterlab
make jupyter

# 安装 jupyterlab 4.3
jupyterlab_version=4.3.0 make jupyter
```

## [superset](https://github.com/apache/superset)

### 安装参数

|  参数  | 含义 | 示例 |
|  ----  | ---- | ---- |
| superset_admin_user | 管理员用户 | superset |
| superset_admin_password | 管理员密码 | supersetpwd |
| superset_port | http 端口 | 8088 |
| superset_database_client | 连接后台数据库的客户端 | pymysql |
| superset_database_host | 数据库 host，如果设置了，将配置 SQLALCHEMY_DATABASE_URI，使得 superset 使用数据库作为存储，默认为 sqlite | localhost |
| superset_database_port | 数据库端口 | 3306 |
| superset_database_user | 数据库用户 | root |
| superset_database_password | 数据库密码 | rootpwd |
| superset_database_db | 数据库名称 | superset |

### 安装

```shell
# 默认安装
make superset

# 安装并配置连接数据库
superset_database_host=localhost superset_database_port=3306 superset_database_user=root superset_database_password=rootpwd make superset

# 初始化
supersetinit

# 启动
supersetstart
```

## [hue](https://github.com/cloudera/hue)

注意: 原版最新分支 branch-4.11.0 通过 python3.8 编译会有报错，我在 [smiecj/hue](https://github.com/smiecj/hue/commit/3d0898066db210dccd029cd66d2423f9a4aa1da2) 的 fork 仓库中修复

### install param

|  param  | usage | example |
|  ----  | ---- | ---- |
| hue_http_port | 服务端口 | 8888 |
| hue_enable_prometheus | 是否开启 prometheus 指标 | true |
| hue_app_blacklist | 组件黑名单 | search,sqoop,pig,security,jobsub,spark,jobbrowser |
| hue_auth_backend | 校验类，在生产环境可配置 oidc、ldap 等 | desktop.auth.backend.AllowFirstUserDjangoBackend |
| hue_db_engine | 数据库类型 | sqlite |
| hue_db_host<br>hue_db_port<br>hue_db_user<br>hue_db_password<br>hue_db_db | 数据库相关配置 | |
| hue_timezone | 时区 | Asia/Shanghai |
| hue_hdfs_namenode_address | hdfs namenode 地址 | namenode_host:8020 |
| hue_hdfs_webhdfs_address | hdfs webhdfs 地址 | webhdfs_host:50070 |
| hue_hive_server_host | hiveserver2 host | hiveserver2_host |
| hue_hive_server_port | hiveserver2 port | 10000 |
| hue_interpreters | 连接器配置，json 数组格式 | '[{"name": "mysql_hue", "interface": "sqlalchemy", "options": {"url": "mysql+mysqldb://root:root@mysql_host:3306/information_schema?charset=utf8mb4"}},{"name": "hive", "display": "hive_xuanwu", "interface": "hiveserver2"},{"name":"starrocks","interface":"sqlalchemy","options":{"url": "starrocks://root:root@starrocks_host:9030?charset=utf8"}}]' |

### install

```shell
# 安装: 依赖 conda，将创建名为 "py_hue" python 3.8 版本的环境
make hue

# install with mysql, hive, hdfs and config interpreters
# 安装并配置 mysql、hdfs、hive 和 starrocks 等连接器
NET=CN hue_http_port=8888 hue_db_host=mysql_host hue_db_port=3306 hue_db_user=root hue_db_password=root hue_db_db=hue hue_hive_server_host=hiveserver2_host hue_hive_server_port=10000 hue_hdfs_namenode_address=namenode_host:8020 hue_hdfs_webhdfs_address=webhdfs_host:50070 interpreters='[{"name": "mysql_hue", "interface": "sqlalchemy", "options": {"url": "mysql+mysqldb://root:root@mysql_host:3306/information_schema?charset=utf8mb4"}},{"name": "hive", "display": "hive", "interface": "hiveserver2"},{"name":"starrocks","interface":"sqlalchemy","options":{"url": "starrocks://root:root@starrocks_host:9030?charset=utf8"}}]' make hue

# init
hueinit

# start
huestart
```

## [flink](https://github.com/apache/flink)

### 安装参数

|  参数  | 含义 | 示例 |
|  ----  | ---- | ---- |
| flink_jobmanager_port | jobmanager 通信端口 | 6123 |
| flink_masters | jobmanager节点 | master1 |
| flink_workers | worker节点 | task1,task2 |
| flink_jobmanager_memory_process_size | jobmanager 内存分配大小 | 1024m |
| flink_jobmanager_memory_jvmmetaspace_size | jobmanager jvm 元空间内存大小 | 512m |
| flink_taskmanager_memory_process_size | taskmanager 内存分配大小 | 1024m |
| flink_taskmanager_memory_jvmmetaspace_size | taskmanager jvm 元空间内存大小 | 512m |
| flink_taskmanager_task_slots | 单个 taskmanager 最多任务数 | 9000 |
| flink_pushgateway_address | pushgateway 地址 | http://localhost:9091 |
| flink_pushgateway_jobname | pushgateway jobname | flink_singleton |
| flink_ha_type | flink 高可用类型 | zookeeper |
| flink_ha_zookeeper_nodes | flink 连接 zookeeper 节点 | localhost:2181 |
| flink_ha_zookeeper_root | flink 信息在 zookeeper 保存的数据节点根路径 | /flink |
| flink_ha_cluster_id | 标识集群名称，本集群信息将会在 /flink_ha_zookeeper_root/flink_ha_cluster_id 路径下 | local_singleton |
| flink_ha_storage_dir | flink 高可用信息保存的路径 | s3://bucket_name/flink_ha |
| flink_state_backend_type | flink 状态保存器类型 | filesystem |
| flink_state_checkpoint_dir | flink checkpoint 保存路径 | s3://bucket_name/flink_checkpoint |

### 安装

```shell
# 单点
make flink

# 3节点集群（每个节点都需要执行）
flink_masters=master1 flink_workers=worker1,worker2,worker3 flink_jobmanager_host=master1 flink_rest_port=8081 make flink

# 高可用3节点集群（每个节点都需要执行）
flink_masters=master1 flink_workers=worker1,worker2,worker3 flink_jobmanager_host=master1 flink_rest_port=8081 flink_ha_type=zookeeper flink_ha_zookeeper_nodes=worker1:2181,worker2:2181,worker3:2181 flink_ha_zookeeper_root=/flink flink_ha_cluster_id=/cluster flink_ha_storage_dir=s3://test_bucket/flink_recovery flink_s3_endpoint=http://minio:9000 flink_s3_access_key=root flink_s3_secret_key=minio_password flink_state_backend_type=filesystem flink_state_checkpoint_dir=s3://test_bucket/flink_cp/ make flink

# 提交 word count example
/opt/modules/flink/bin/flink run /opt/modules/flink/examples/batch/WordCount.jar
```

## [flink-cdc](https://github.com/apache/flink-cdc)

```shell
# 安装
make flink-cdc

# 提交任务
# 任务模板参考: https://nightlies.apache.org/flink/flink-cdc-docs-master/docs/get-started/quickstart/mysql-to-starrocks/#submit-job-with-flink-cdc-cli
/opt/modules/flink-cdc/bin/flink-cdc.sh /opt/modules/flink-cdc/test.yaml
```

## [zookeeper](https://github.com/apache/zookeeper)

```shell
# 安装单点
make zookeeper

# 安装三节点集群
## 注意: 每个节点都需要执行
zookeeper_servers=zk_node1:2888:3888,zk_node2:2888:3888,zk_node3:2888:3888 make zookeeper

## 初始化 zookeeper 配置（启动前需要执行）
zookeeperinit

## 启动 zookeeper（每个节点都需要执行）
zookeeperstart

## 连接 zookeeper
zookeeperconnect
```

## [kafka](https://github.com/apache/kafka)

```shell
# 安装 kafka 单点 (使用 localhost:2181 作为 zookeeper)
make kafka

# 安装三节点集群
## 注意: 每个节点都需要执行
kafka_installed_hosts=kafka_node1,kafka_node2,kafka_node3 kafka_zookeeper_nodes=zk_node1:2181,zk_node2:2181,zk_node3:2181 make kafka

## 初始化 kafka 配置（启动前需要执行）
kafkainit

## 启动 kafka（每个节点都需要执行）
kafkastart
```

## [clickhouse](https://github.com/ClickHouse/ClickHouse)

### 安装参数

|  参数  | 含义 | 示例 |
|  ----  | ---- | ---- |
| clickhouse_cluster_name | 集群名称 | my_emr |
| clickhouse_data_path | 数据存储路径 | /opt/data/clickhouse/data |
| clickhouse_tmp_path | 临时数据路径 | /opt/data/clickhouse/tmp |
| clickhouse_server_http_port | http端口 | 8123 |
| clickhouse_server_tcp_port | tcp端口 | 9000 |
| clickhouse_server_mysql_port | mysql端口 | 9004 |
| clickhouse_server_postgresql_port | pgsql端口 | 9005 |
| clickhouse_server_interserver_http_port | 用于内部通信的http端口 | 9009 |
| clickhouse_server_max_connections | 最大连接数 | 4096 |
| clickhouse_server_max_concurrent_queries | 最大同时查询连接数 | 100 |
| clickhouse_server_monitor_port | 监控端口 | 9363 |
| clickhouse_server_zookeeper_nodes | zookeeper地址，多个逗号分隔 | zk_host_1:2181 |
| clickhouse_server_nodes | clickhouse集群地址 | ck_host_1,ck_host_2,ck_host_3 |
| clickhouse_init_database_name | 默认数据库 | ckdb
| clickhouse_user_normal_user | 普通用户，多个分号分隔 | ck_user_1 |
| clickhouse_user_normal_user_allow_database | 普通用户可访问数据库，和normal_user的分隔方式对应 | ck_db_1 |
| clickhouse_user_normal_user_password | 普通用户密码，和normal_user的分隔方式对应 | ck_user_pwd_1 |

### 安装 clickhouse

```shell
# 安装 clickhouse 单点
NET=CN clickhouse_version=22.12.6.22 clickhouse_cluster_name=local_singleton clickhouse_server_zookeeper_nodes=localhost:2181 clickhouse_server_nodes=node1 clickhouse_data_path=/opt/data/clickhouse/data clickhouse_tmp_path=/opt/data/clickhouse/tmp make clickhouse

# 安装 clickhouse 集群
clickhouse_cluster_name=local_cluster clickhouse_server_zookeeper_nodes=zk_node1:2181 clickhouse_server_nodes=node1,node2,node3 clickhouse_data_path=/opt/data/clickhouse/data clickhouse_user_normal_user=normal clickhouse_user_normal_user_password=normal_pwd clickhouse_user_normal_user_allow_database=test,temp,d_shop clickhouse_tmp_path=/opt/data/clickhouse/tmp make clickhouse
```

## [clickhouse copier](https://github.com/ClickHouse/copier)

### params

|  参数  | 含义 | 示例 |
|  ----  | ---- | ---- |
| clickhouse_copier_zookeeper_nodes | zookeeper地址，多个逗号分隔 | zk_host_1:2181 |
| clickhouse_copier_source_server_nodes | 源集群地址，多个逗号分隔 | ck_source_host_1 |
| clickhouse_copier_target_server_nodes | 目标集群地址 | ck_target_host_1 |
| clickhouse_server_tcp_port | 集群tcp端口 | 9000 |
| clickhouse_copier_source_cluster_name | 源集群名 | ck_source_my_cluster |
| clickhouse_copier_target_cluster_name | 目标集群名, 注意和目标集群名不能一样 | ck_target_my_cluster |
| clickhouse_copier_num_splits | 拷贝分区数据时对数据分块大小 | 1 |
| clickhouse_copier_task_path | zookeeper上保存的任务配置根路径 | /copier/task |
| clickhouse_copier_base_dir | 保存在本地的任务临时路径，包含任务执行日志，临时数据等 | /opt/modules/clickhouse/copier/base |
| clickhouse_copier_migrate_enabled | 是否执行数据同步，默认开启，否则将只生成同步配置和建表语句，不执行数据同步操作 | 1 |
| clickhouse_copier_copy_exists_table | 是否同步已存在的表，可能会导致数据重复 | 1 |
| clickhouse_copier_recreate_table | 对目标集群是否先删表再同步 | 0 |
| clickhouse_copier_allow_database | 允许同步的数据库 | 1 |
| clickhouse_copier_allow_tables | 允许同步的表，正则格式 | 1 |
| clickhouse_copier_enabled_partitions | 指定拷贝的分区，多个逗号分隔 | 20240714,20240715 |

### commands

```shell
# 安装 copier
make clickhouse-copier

# 完整拷贝: 除了系统表所有表的数据都将执行 copier 任务进行拷贝
# 提示: copier 不会对数据去重，多次导入可能会导致数据也重复
make clickhouse-copy-cluster
```

## lvim

安装 neovim 、 lvim 、 cargo

```
make lvim
```

## media: 媒体相关工具

### icecast

```shell
# 安装 icecast
make icecast

# 安装 ezstream
make ezstream

# 启动 icecast
icecastinit
icecaststart

# 通过 ezsteam 推流
ezstream -c ez.xml
```

### 其他工具

```
# 安装 ffmpeg
## 注意: ffmpeg 默认安装在 /usr/local (${PREFIX}) 路径，因此执行前需要执行 export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
make ffmpeg

# 安装 opencc
make opencc

# 安装 mediainfo
make mediainfo

# 安装 metaflac
make metaflac

# 安装 imagemagick
make imagemagick
```

## media: navidrome

```
# 安装 navidrome
make navidrome

# 安装并指定音乐数据和sqlite数据所在路径
navidrome_music_folder=/opt/data/navidrome/music navidrome_data_folder=/opt/data/navidrome/data make navidrome
```