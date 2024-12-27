#!/bin/bash
set -eo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

export prometheus_home=${modules_home}/prometheus

copy_scripts() {
    cp ./scripts/* /usr/local/bin/
    chmod +x /usr/local/bin/prometheus*
    sed -i "s#{prometheus_home}#${prometheus_home}#g" /usr/local/bin/prometheus*
}

if [ -d "${prometheus_home}" ]; then
    echo "prometheus path ${prometheus_home} not empty, will only copy scripts"
    copy_scripts
    exit 0
fi

## install prometheus

rm -rf ${prometheus_home} && mkdir -p ${prometheus_home}
pushd ${prometheus_home}

prometheus_folder=prometheus-${prometheus_version}.linux-${ARCH_SHORT}
prometheus_pkg=${prometheus_folder}.tar.gz
prometheus_pkg_url=${github_url}/prometheus/prometheus/releases/download/v${prometheus_version}/${prometheus_pkg}
rm -f ${prometheus_pkg} && wget ${prometheus_pkg_url} && tar -xzvf ${prometheus_pkg} && rm ${prometheus_pkg}
mv ./${prometheus_folder}/* ./ && rm -r ${prometheus_folder}

popd

cp ./conf/* ${prometheus_home}

copy_scripts

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${prometheus_home}/prometheus.properties
done

popd