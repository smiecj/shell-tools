#!/bin/bash
set -exo pipefail

grafana_home=${modules_home}/grafana

system_arch=`uname -p`

arch=`uname -p`
if [ "x86_64" == "${arch}" ]; then
    arch="amd64"
elif [ "aarch64" == "${arch}" ]; then
    arch="arm64"
fi

## install grafana

rm -rf ${grafana_home} && mkdir -p ${grafana_home}
pushd ${grafana_home}

grafana_folder=grafana-${grafana_version}
grafana_pkg=grafana-enterprise-${grafana_version}.linux-${arch}.tar.gz

if [[ ${grafana_repo} =~ *"dl.grafana.com"* ]]
then
    grafana_pkg_url=${grafana_repo}/${grafana_pkg}
else
    grafana_pkg_url=${grafana_repo}/${grafana_version}/${grafana_pkg}
fi

rm -f ${grafana_pkg} && wget ${grafana_pkg_url} && tar -xzvf ${grafana_pkg} && rm ${grafana_pkg}
mv ${grafana_folder}/* ./ && rm -r ${grafana_folder}

popd

# start
## nohup /opt/modules/grafana/bin/grafana-server --homepath "/opt/modules/grafana" --config "/opt/modules/grafana/conf/custom.ini" >> /opt/modules/grafana/test.log 2>&1 &