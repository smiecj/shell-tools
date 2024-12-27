# shell tools

shells for install development environment, middleware components and execuable tools more conveniently

[中文](https://github.com/smiecj/shell-tools/blob/master/README_zh.md)

## gcc, glibc, cmake & make

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

install zsh

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

install conda & python3

```
make python
```

only install conda

```
make conda
```

## nodejs

install nodejs

```
make nodejs
```

## java

install java (1.8 & 17), maven, gradle, ant

```
make java
```

install specify version jdk

```shell
# install jdk 21
# notice: for not conflict with system java in common situation, this command will add "JDK_HOME" env to /etc/profile rather than "JAVA_HOME"
jdk_version=21 make jdk
```

install maven

```
make maven
```

## golang

install golang

```
make golang
```

## php

install php

```
make php
```

## rust

install rust

```
make rust
```

## [git](https://github.com/git/git)

install git

```
make git
```

## [jq](https://github.com/jqlang/jq)

install jq

```
make jq
```

## [code server](https://github.com/coder/code-server)

```shell
make codeserver
```

## [prometheus](https://github.com/prometheus/prometheus)

```shell
# install prometheus, alertmanager, pushgateway and node exporter
prometheus_jobs=pushgateway__localhost:9091::node_exporter__localhost:9100 prometheus_alertmanager_address=localhost:3002 make monitor-prometheus

# install prometheus only
make prometheus
```

## [grafana](https://github.com/grafana/grafana)

```shell
# install grafana
make grafana
```

## [httpd](https://github.com/apache/httpd)

```shell
# install httpd
make httpd
```

## [mysql](https://github.com/mysql/mysql-server)

```shell
# prepare: install rpcgen
make rpcgen

# compile and install mysql 5.7.44
mysql_skip_abi_check=true mysql_version=5.7.44 make mysql

# compile and install mysql 8.0.39
mysql_version=8.0.39 make mysql

# specify data path and root password
mysql_version=8.0.39 mysql_data_dir=/opt/data/mysql mysql_root_password=rootMySQLPwd1 make mysql

# init mysql storage path and default root password
# notice: root password will only modify at first init
mysqlinit

# start
mysqlstart

# connect mysql
mysqlconnect
```

## [jupyter](https://github.com/jupyterhub/jupyterhub)

```shell
# will install jupyterhub and jupyterlab
make jupyter

# install jupyterlab 4.3
jupyterlab_version=4.3.0 make jupyter
```

## [superset](https://github.com/apache/superset)

### install param

|  param  | usage | example |
|  ----  | ---- | ---- |
| superset_admin_user | login admin user | superset |
| superset_admin_password | login admin password | supersetpwd |
| superset_port | http port | 8088 |
| superset_database_client | connect database client | pymysql |
| superset_database_host | database host, if it is set, will init SQLALCHEMY_DATABASE_URI env | localhost |
| superset_database_port | database port | 3306 |
| superset_database_user | database user | root |
| superset_database_password | database password | rootpwd |
| superset_database_db | database name | superset |

### install

```shell
# install
make superset

# install and set database mysql 
superset_database_host=localhost superset_database_port=3306 superset_database_user=root
superset_database_password=rootpwd make superset

# init
supersetinit

# start
supersetstart
```

## [hue](https://github.com/cloudera/hue)

notice: fix compile with python 3.8 at fork branch 4.11 in [smiecj/hue](https://github.com/smiecj/hue/commit/3d0898066db210dccd029cd66d2423f9a4aa1da2)

### install param

|  param  | usage | example |
|  ----  | ---- | ---- |
| hue_http_port | service port | 8888 |
| hue_enable_prometheus | enable prometheus | true |
| hue_app_blacklist | app black list | search,sqoop,pig,security,jobsub,spark,jobbrowser |
| hue_auth_backend | auth backend, at company you can config oidc or ldap | desktop.auth.backend.AllowFirstUserDjangoBackend |
| hue_db_engine | db engine | sqlite |
| hue_db_host<br>hue_db_port<br>hue_db_user<br>hue_db_password<br>hue_db_db | hue db config | |
| hue_timezone | timezone | Asia/Shanghai |
| hue_hdfs_namenode_address | hdfs namenode address | namenode_host:8020 |
| hue_hdfs_webhdfs_address | hdfs webhdfs address | webhdfs_host:50070 |
| hue_hive_server_host | hiveserver2 host | hiveserver2_host |
| hue_hive_server_port | hiveserver2 port | 10000 |
| hue_interpreters | hue interpreters config, a json array | '[{"name": "mysql_hue", "interface": "sqlalchemy", "options": {"url": "mysql+mysqldb://root:root@mysql_host:3306/information_schema?charset=utf8mb4"}},{"name": "hive", "display": "hive_xuanwu", "interface": "hiveserver2"},{"name":"starrocks","interface":"sqlalchemy","options":{"url": "starrocks://root:root@starrocks_host:9030?charset=utf8"}}]' |

### install

```shell
# install: depend conda to install python env "py_hue" (3.8)
make hue

# install with mysql, hive, hdfs and config interpreters
NET=CN hue_http_port=8888 hue_db_host=mysql_host hue_db_port=3306 hue_db_user=root hue_db_password=root hue_db_db=hue hue_hive_server_host=hiveserver2_host hue_hive_server_port=10000 hue_hdfs_namenode_address=namenode_host:8020 hue_hdfs_webhdfs_address=webhdfs_host:50070 interpreters='[{"name": "mysql_hue", "interface": "sqlalchemy", "options": {"url": "mysql+mysqldb://root:root@mysql_host:3306/information_schema?charset=utf8mb4"}},{"name": "hive", "display": "hive", "interface": "hiveserver2"},{"name":"starrocks","interface":"sqlalchemy","options":{"url": "starrocks://root:root@starrocks_host:9030?charset=utf8"}}]' make hue

# init
hueinit

# start
huestart
```

## [flink](https://github.com/apache/flink)

### install param

|  param  | usage | example |
|  ----  | ---- | ---- |
| flink_jobmanager_port | jobmanager rpc port | 6123 |
| flink_masters | jobmanager nodes | master1 |
| flink_workers | worker nodes | task1,task2 |
| flink_jobmanager_memory_process_size | jobmanager processs memory size | 1024m |
| flink_jobmanager_memory_jvmmetaspace_size | jobmanager jvm metaspace memory size | 512m |
| flink_taskmanager_memory_process_size | taskmanager process memory size | 1024m |
| flink_taskmanager_memory_jvmmetaspace_size | taskmanager jvm 元空间内存大小 | 512m |
| flink_taskmanager_task_slots | max tasks run on a taskmanager | 10 |
| flink_pushgateway_address | pushgateway address | http://localhost:9091 |
| flink_pushgateway_jobname | pushgateway jobname | flink_singleton |
| flink_ha_type | flink ha type | zookeeper |
| flink_ha_zookeeper_nodes | flink connect zookeeper nodes | localhost:2181 |
| flink_ha_zookeeper_root | flink info store in zookeeper path root | /flink |
| flink_ha_cluster_id | cluster id, then flink cluster info will store in /flink_ha_zookeeper_root/flink_ha_cluster_id | local_singleton |
| flink_ha_storage_dir | flink ha info store path | s3://bucket_name/flink_ha |
| flink_state_backend_type | flink state store type | filesystem |
| flink_state_checkpoint_dir | flink checkpoint store path | s3://bucket_name/flink_checkpoint |

### install

```shell
# singleton
make flink

# 3 nodes cluster (need execute on each node)
flink_masters=master1 flink_workers=worker1,worker2,worker3 flink_jobmanager_host=master1 flink_rest_port=8081 make flink

# 3 nodes cluster with ha (need execute on each node)
flink_masters=master1 flink_workers=worker1,worker2,worker3 flink_jobmanager_host=master1 flink_rest_port=8081 flink_ha_type=zookeeper flink_ha_zookeeper_nodes=worker1:2181,worker2:2181,worker3:2181 flink_ha_zookeeper_root=/flink flink_ha_cluster_id=/cluster flink_ha_storage_dir=s3://test_bucket/flink_recovery flink_s3_endpoint=http://minio:9000 flink_s3_access_key=root flink_s3_secret_key=minio_password flink_state_backend_type=filesystem flink_state_checkpoint_dir=s3://test_bucket/flink_cp/ make flink

# submit word count example
/opt/modules/flink/bin/flink run /opt/modules/flink/examples/batch/WordCount.jar
```

## [flink-cdc](https://github.com/apache/flink-cdc)

```shell
# install
make flink-cdc

# submit job
# job template: https://nightlies.apache.org/flink/flink-cdc-docs-master/docs/get-started/quickstart/mysql-to-starrocks/#submit-job-with-flink-cdc-cli
/opt/modules/flink-cdc/bin/flink-cdc.sh /opt/modules/flink-cdc/test.yaml
```

## [zookeeper](https://github.com/apache/zookeeper)

```shell
# install singleton
make zookeeper

# install zookeeper 3 node cluster
## notice: need execute on each node
zookeeper_servers=zk_node1:2888:3888,zk_node2:2888:3888,zk_node3:2888:3888 make zookeeper

## init zookeeper (execute on each node before start)
zookeeperinit

## start zookeeper (execute on each node)
zookeeperstart

## connect zookeeper
zookeeperconnect
```

## [kafka](https://github.com/apache/kafka)

```shell
# kafka install singleton (use localhost:2181 as zookeeper)
make kafka

# install kafka 3 node cluster
## notice: need execute on each node
kafka_installed_hosts=kafka_node1,kafka_node2,kafka_node3 kafka_zookeeper_nodes=zk_node1:2181,zk_node2:2181,zk_node3:2181 make kafka

## init kafka (execute on each node before start)
kafkainit

## start kafka (execute on each node)
kafkastart
```

## [clickhouse](https://github.com/ClickHouse/ClickHouse)

### install param

|  param  | usage | example |
|  ----  | ---- | ---- |
| clickhouse_cluster_name | cluster name | my_emr |
| clickhouse_data_path | data path | /opt/data/clickhouse/data |
| clickhouse_tmp_path | tmp data path | /opt/data/clickhouse/tmp |
| clickhouse_server_http_port | http port | 8123 |
| clickhouse_server_tcp_port | tcp port | 9000 |
| clickhouse_server_mysql_port | mysql port | 9004 |
| clickhouse_server_postgresql_port | pgsql port | 9005 |
| clickhouse_server_interserver_http_port | http port for inter | 9009 |
| clickhouse_server_max_connections | max connections | 4096 |
| clickhouse_server_max_concurrent_queries | max concurrent queries | 100 |
| clickhouse_server_monitor_port | monitor port | 9363 |
| clickhouse_server_zookeeper_nodes | zookeeper nodes | zk_host_1:2181,zk_host_2:2181,zk_host_3:2181 |
| clickhouse_server_nodes | clickhouse nodes | ck_host_1,ck_host_2,ck_host_3 |
| clickhouse_init_database_name | default database name | ckdb |
| clickhouse_user_normal_user | normal user | ck_user_1 |
| clickhouse_user_normal_user_allow_database | normal user can access database, split with same order as "clickhouse_user_normal_user" | ck_db_1 |
| clickhouse_user_normal_user_password | normal user password, split with same order as "clickhouse_user_normal_user" | ck_user_pwd_1 |

### install clickhouse

```shell
# singleton
NET=CN clickhouse_version=22.12.6.22 clickhouse_cluster_name=local_singleton clickhouse_server_zookeeper_nodes=localhost:2181 clickhouse_server_nodes=node1 clickhouse_data_path=/opt/data/clickhouse/data clickhouse_tmp_path=/opt/data/clickhouse/tmp make clickhouse

# cluster
clickhouse_cluster_name=local_cluster clickhouse_server_zookeeper_nodes=zk_node1:2181 clickhouse_server_nodes=node1,node2,node3 clickhouse_data_path=/opt/data/clickhouse/data clickhouse_user_normal_user=normal clickhouse_user_normal_user_password=normal_pwd clickhouse_user_normal_user_allow_database=test,temp,d_shop clickhouse_tmp_path=/opt/data/clickhouse/tmp make clickhouse
```

## [clickhouse copier](https://github.com/ClickHouse/copier)

### params

|  param  | usage | example |
|  ----  | ---- | ---- |
| clickhouse_copier_zookeeper_nodes | zookeeper nodes | zk_host_1:2181,zk_host_2:2181,zk_host_3:2181 |
| clickhouse_copier_source_server_nodes | source cluster nodes | ck_source_host_1,ck_source_host_2,ck_source_host_3 |
| clickhouse_copier_target_server_nodes | target cluster nodes | ck_target_host_1,ck_target_host_2,ck_target_host_3 |
| clickhouse_server_tcp_port | cluster tcp port | 9000 |
| clickhouse_copier_source_cluster_name | source cluster name | ck_source_my_cluster |
| clickhouse_copier_target_cluster_name | target cluster name, should not be same as source cluster name | ck_target_my_cluster |
| clickhouse_copier_num_splits | job split | 1 |
| clickhouse_copier_task_path | job config saved on zookeeper | /copier/task |
| clickhouse_copier_base_dir | job config file saved path | /opt/modules/clickhouse/copier/base |
| clickhouse_copier_migrate_enabled | data copy is enabled, if not, will only generate config xml and sql file and not execute | 1 |
| clickhouse_copier_copy_exists_table | whether copy exists table, sync multiple times may cause data duplicate | 1 |
| clickhouse_copier_recreate_table | whether recreate table on target cluster | 0 |
| clickhouse_copier_allow_database | database allow to sync | 1 |
| clickhouse_copier_allow_tables | tables allow to sync (regexp) | 1 |
| clickhouse_copier_enabled_partitions | partitions allow to sync | 20240714,20240715 |

### commands

```shell
# install copier
make clickhouse-copier

# full migrate: all tables except system table (information_schema, system) will copy to target cluster
# notice: copier will not check data uniqueness, multiple copy may cause data duplicate
make clickhouse-copy-cluster
```

## lvim

install neovim & lvim & cargo

```
make lvim
```

## media: tools

### icecast

```shell
# install icecast
make icecast

# install ezstream
make ezstream

# start icecast
icecastinit
icecaststart

# live stream by ezstream
ezstream -c ez.xml
```

### other tools

```
# install ffmpeg
## default install at /usr/local, need execute this: export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
make ffmpeg

# install opencc
make opencc

# install mediainfo
make mediainfo

# install metaflac
make metaflac

# install imagemagick
make imagemagick
```

## media: navidrome

```
# install navidrome
make navidrome

# install and specify music and data path
navidrome_music_folder=/opt/data/navidrome/music navidrome_data_folder=/opt/data/navidrome/data make navidrome
```