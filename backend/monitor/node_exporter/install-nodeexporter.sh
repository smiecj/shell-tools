#!/bin/bash
set -eo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

export node_exporter_home=${modules_home}/node_exporter

copy_scripts() {
    cp ./scripts/* /usr/local/bin/
    chmod +x /usr/local/bin/nodeexporter*
    sed -i "s#{node_exporter_home}#${node_exporter_home}#g" /usr/local/bin/nodeexporter*
}

if [ -d "${node_exporter_home}" ]; then
    echo "node exporter path ${node_exporter_home} not empty, will only copy scripts"
    copy_scripts
    exit 0
fi

## install node exporter

rm -rf ${node_exporter_home} && mkdir -p ${node_exporter_home}
pushd ${node_exporter_home}

node_exporter_folder=node_exporter-${node_exporter_version}.linux-${ARCH_SHORT}
node_exporter_pkg=${node_exporter_folder}.tar.gz
node_exporter_pkg_url=${github_url}/prometheus/node_exporter/releases/download/v${node_exporter_version}/${node_exporter_pkg}

rm -f ${node_exporter_pkg}
rm -rf ${node_exporter_folder}
curl -LO ${node_exporter_pkg_url}
tar -xzvf ${node_exporter_pkg}
rm ${node_exporter_pkg}

mv ./${node_exporter_folder}/* ./
rm -r ${node_exporter_folder}

popd

cp ./conf/* ${node_exporter_home}

copy_scripts

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${node_exporter_home}/node_exporter.properties
done

popd
