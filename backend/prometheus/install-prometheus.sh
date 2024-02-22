#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

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

cp ./scripts/* /usr/local/bin/
chmod +x /usr/local/bin/prometheus*
sed -i "s#{prometheus_home}#${prometheus_home}#g" /usr/local/bin/prometheus*
sed -i "s#{prometheus_port}#${prometheus_port}#g" /usr/local/bin/prometheus*

## install alertmanager

rm -rf ${alertmanager_home} && mkdir -p ${alertmanager_home}
pushd ${alertmanager_home}

alertmanager_folder=alertmanager-${alertmanager_version}.linux-${arch}
alertmanager_pkg=${alertmanager_folder}.tar.gz
alertmanager_pkg_url=${github_url}/prometheus/alertmanager/releases/download/v${alertmanager_version}/${alertmanager_pkg}
rm -f ${alertmanager_pkg} && wget ${alertmanager_pkg_url} && tar -xzvf ${alertmanager_pkg} && rm ${alertmanager_pkg}
mv ${alertmanager_folder}/* ./ && rm -r ${alertmanager_folder}

popd

chmod +x /usr/local/bin/alertmanager*
sed -i "s#{alertmanager_home}#${alertmanager_home}#g" /usr/local/bin/alertmanager*
sed -i "s#{alertmanager_port}#${alertmanager_port}#g" /usr/local/bin/alertmanager*

## install pushgateway

rm -rf ${pushgateway_home} && mkdir -p ${pushgateway_home}
pushd ${pushgateway_home}

pushgateway_folder=pushgateway-${pushgateway_version}.linux-${arch}
pushgateway_pkg=pushgateway-${pushgateway_version}.linux-${arch}.tar.gz
pushgateway_pkg_url=${github_url}/prometheus/pushgateway/releases/download/v${pushgateway_version}/${pushgateway_pkg}
rm -f ${pushgateway_pkg} && wget ${pushgateway_pkg_url} && tar -xzvf ${pushgateway_pkg} && rm ${pushgateway_pkg}
mv ${pushgateway_folder}/* ./ && rm -r ${pushgateway_folder}

popd

chmod +x /usr/local/bin/pushgateway*
sed -i "s#{pushgateway_home}#${pushgateway_home}#g" /usr/local/bin/pushgateway*
sed -i "s#{pushgateway_port}#${pushgateway_port}#g" /usr/local/bin/pushgateway*

## install node exporter

rm -rf ${node_exporter_home} && mkdir -p ${node_exporter_home}
pushd ${node_exporter_home}

node_exporter_folder=node_exporter-${node_exporter_version}.linux-${arch}
node_exporter_pkg=${node_exporter_folder}.tar.gz
node_exporter_pkg_url=${github_url}/prometheus/node_exporter/releases/download/v${node_exporter_version}/${node_exporter_pkg}
rm -f ${node_exporter_pkg} && wget ${node_exporter_pkg_url} && tar -xzvf ${node_exporter_pkg} && rm ${node_exporter_pkg}
mv ${node_exporter_folder}/* ./ && rm -r ${node_exporter_folder}

popd

chmod +x /usr/local/bin/nodeexporter*
sed -i "s#{node_exporter_home}#${node_exporter_home}#g" /usr/local/bin/nodeexporter*
sed -i "s#{node_exporter_port}#${node_exporter_port}#g" /usr/local/bin/nodeexporter*

popd