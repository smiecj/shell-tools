#!/bin/bash
set -exo pipefail

prometheus_home=${modules_home}/prometheus
alertmanager_home=${modules_home}/alertmanager
pushgateway_home=${modules_home}/pushgateway
node_exporter_home=${modules_home}/node_exporter

system_arch=`uname -p`

arch=`uname -p`
if [ "x86_64" == "${arch}" ]; then
    arch="amd64"
elif [ "aarch64" == "${arch}" ]; then
    arch="arm64"
fi


## install prometheus

rm -rf ${prometheus_home} && mkdir -p ${prometheus_home}
pushd ${prometheus_home}

prometheus_folder=prometheus-${prometheus_version}.linux-${arch}
prometheus_pkg=${prometheus_folder}.tar.gz
prometheus_pkg_url=${github_url}/prometheus/prometheus/releases/download/v${prometheus_version}/${prometheus_pkg}
rm -f ${prometheus_pkg} && wget ${prometheus_pkg_url} && tar -xzvf ${prometheus_pkg} && rm ${prometheus_pkg}
mv ${prometheus_folder}/* ./ && rm -r ${prometheus_folder}

popd

## install alertmanager

rm -rf ${alertmanager_home} && mkdir -p ${alertmanager_home}
pushd ${alertmanager_home}

alertmanager_folder=alertmanager-${alertmanager_version}.linux-${arch}
alertmanager_pkg=${alertmanager_folder}.tar.gz
alertmanager_pkg_url=${github_url}/prometheus/alertmanager/releases/download/v${alertmanager_version}/${alertmanager_pkg}
rm -f ${alertmanager_pkg} && wget ${alertmanager_pkg_url} && tar -xzvf ${alertmanager_pkg} && rm ${alertmanager_pkg}
mv ${alertmanager_folder}/* ./ && rm -r ${alertmanager_folder}

popd

## install pushgateway

rm -rf ${pushgateway_home} && mkdir -p ${pushgateway_home}
pushd ${pushgateway_home}

pushgateway_folder=pushgateway-${pushgateway_version}.linux-${arch}
pushgateway_pkg=pushgateway-${pushgateway_version}.linux-${arch}.tar.gz
pushgateway_pkg_url=${github_url}/prometheus/pushgateway/releases/download/v${pushgateway_version}/${pushgateway_pkg}
rm -f ${pushgateway_pkg} && wget ${pushgateway_pkg_url} && tar -xzvf ${pushgateway_pkg} && rm ${pushgateway_pkg}
mv ${pushgateway_folder}/* ./ && rm -r ${pushgateway_folder}

popd

## install node exporter

rm -rf ${node_exporter_home} && mkdir -p ${node_exporter_home}
pushd ${node_exporter_home}

node_exporter_folder=node_exporter-${node_exporter_version}.linux-${arch}
node_exporter_pkg=${node_exporter_folder}.tar.gz
node_exporter_pkg_url=${github_url}/prometheus/node_exporter/releases/download/v${node_exporter_version}/${node_exporter_pkg}
rm -f ${node_exporter_pkg} && wget ${node_exporter_pkg_url} && tar -xzvf ${node_exporter_pkg} && rm ${node_exporter_pkg}
mv ${node_exporter_folder}/* ./ && rm -r ${node_exporter_folder}

popd

## prometheus start

## alertmanager start

## pushgateway start

## node exporter start