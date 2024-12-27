ROOT = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
include $(ROOT)/Makefile.vars.repo
include $(ROOT)/Makefile.vars.version
include $(ROOT)/Makefile.vars.system
include $(ROOT)/Makefile.vars.service
export

hello:
	@echo "hello shell tools!"
	@echo "os: ${OS}"
	@echo "arch: ${ARCH} - ${ARCH_SHORT}"
	@echo "installer: ${INSTALLER}"
	@echo "system version: ${SYSTEM_VERSION}"

zsh:
	bash ./system/install-zsh.sh

lvim:
	bash ./system/install-lvim.sh

texinfo:
	bash ./system/install-texinfo.sh

openssl:
	bash ./system/install-openssl.sh

flex:
	bash ./system/install-flex.sh

rpcgen:
	bash ./system/install-rpcgen.sh

binutils:
	bash ./system/install-binutils.sh

ninja:
	bash ./dev/install-ninja.sh

clang:
	bash ./dev/install-clang.sh

java:
	bash ./dev/install-java.sh

jdk:
	bash ./dev/install-jdk.sh ${jdk_version} JDK_HOME false

maven:
	bash ./dev/install-maven.sh

ant:
	bash ./dev/install-ant.sh

conda:
	bash ./dev/conda/install-conda.sh

python:
	bash ./dev/install-python.sh

golang:
	bash ./dev/install-golang.sh

nodejs:
	bash ./dev/install-nodejs.sh

rust:
	bash ./dev/install-rust.sh

php:
	bash ./dev/install-php.sh

gcc:
	bash ./dev/install-gcc.sh

glibc:
	bash ./dev/install-glibc.sh

glog:
	bash ./dev/install-glog.sh

cmake:
	bash ./dev/install-cmake.sh

gmake:
	bash ./dev/install-make.sh

make:
	bash ./dev/install-make.sh

protobuf:
	bash ./dev/install-protobuf.sh

git:
	bash ./dev/install-git.sh

jq:
	bash ./dev/install-jq.sh

codeserver:
	bash ./backend/codeserver/install-codeserver.sh

jupyter:
	bash ./backend/jupyter/install-jupyter.sh

prometheus:
	bash ./backend/monitor/prometheus/install-prometheus.sh

alertmanager:
	bash ./backend/monitor/alertmanager/install-alertmanager.sh

nodeexporter:
	bash ./backend/monitor/node_exporter/install-nodeexporter.sh

pushgateway:
	bash ./backend/monitor/pushgateway/install-pushgateway.sh

monitor-prometheus:
	bash ./backend/monitor/install-prometheus-all.sh

grafana:
	bash ./backend/grafana/install-grafana.sh

httpd:
	bash ./backend/httpd/install-httpd.sh

mysql:
	bash backend/mysql/install-mysql.sh

zookeeper:
	bash backend/zookeeper/install-zookeeper.sh

kafka:
	bash backend/kafka/install-kafka.sh

mongo:
	bash backend/mongo/install-mongo.sh

flink:
	bash emr/flink/install-flink.sh

flink-cdc:
	bash emr/flink/cdc/install-flink-cdc.sh

clickhouse:
	bash emr/clickhouse/install-clickhouse.sh

clickhouse-copier:
	bash emr/clickhouse/copier/install-copier.sh

clickhouse-copy-cluster:
	bash emr/clickhouse/copier/copy-cluster.sh

doris:
	bash emr/doris/install-doris.sh

superset:
	bash backend/superset/install-superset.sh

hue:
	bash emr/hue/install-hue.sh

minio:
	bash emr/minio/install-minio.sh

bmon:
	bash system/install-bmon.sh

# media

navidrome:
	bash ./life/media/navidrome/install-navidrome.sh

ffmpeg:
	bash ./life/media/install-ffmpeg.sh

icecast:
	bash ./life/media/icecast/install-icecast.sh

opencc:
	bash ./life/media/install-opencc.sh

mediainfo:
	bash ./life/media/install-mediainfo.sh

metaflac:
	bash ./life/media/install-metaflac.sh

imagemagick:
	bash ./life/media/install-imagemagick.sh

libvips:
	bash ./life/media/install-libvips.sh

taglib:
	bash ./life/media/install-taglib.sh