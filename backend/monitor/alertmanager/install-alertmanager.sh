#!/bin/bash
set -eo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

export alertmanager_home=${modules_home}/alertmanager

copy_scripts() {
    cp ./scripts/* /usr/local/bin/
    chmod +x /usr/local/bin/alertmanager*
    sed -i "s#{alertmanager_home}#${alertmanager_home}#g" /usr/local/bin/alertmanager*
}

if [ -d "${alertmanager_home}" ]; then
    echo "alertmanager path ${alertmanager_home} not empty, will only copy scripts"
    copy_scripts
    exit 0
fi

## install alertmanager

rm -rf ${alertmanager_home} && mkdir -p ${alertmanager_home}
pushd ${alertmanager_home}

alertmanager_folder=alertmanager-${alertmanager_version}.linux-${ARCH_SHORT}
alertmanager_pkg=${alertmanager_folder}.tar.gz
alertmanager_pkg_url=${github_url}/prometheus/alertmanager/releases/download/v${alertmanager_version}/${alertmanager_pkg}
rm -f ${alertmanager_pkg} && wget ${alertmanager_pkg_url} && tar -xzvf ${alertmanager_pkg} && rm ${alertmanager_pkg}
mv ./${alertmanager_folder}/* ./ && rm -r ${alertmanager_folder}

popd

cp ./conf/* ${alertmanager_home}

copy_scripts

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${alertmanager_home}/alertmanager.properties
done

popd