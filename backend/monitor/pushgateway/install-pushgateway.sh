#!/bin/bash
set -eo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

export pushgateway_home=${modules_home}/pushgateway

copy_scripts() {
    cp ./scripts/* /usr/local/bin/
    chmod +x /usr/local/bin/pushgateway*
    sed -i "s#{pushgateway_home}#${pushgateway_home}#g" /usr/local/bin/pushgateway*
}

if [ -d "${pushgateway_home}" ]; then
    echo "pushgateway path ${pushgateway_home} not empty, will only copy scripts"
    copy_scripts
    exit 0
fi

## install pushgateway

rm -rf ${pushgateway_home} && mkdir -p ${pushgateway_home}
pushd ${pushgateway_home}

pushgateway_folder=pushgateway-${pushgateway_version}.linux-${ARCH_SHORT}
pushgateway_pkg=${pushgateway_folder}.tar.gz
pushgateway_pkg_url=${github_url}/prometheus/pushgateway/releases/download/v${pushgateway_version}/${pushgateway_pkg}

rm -f ${pushgateway_pkg}
rm -rf ${pushgateway_folder}
curl -LO ${pushgateway_pkg_url}
tar -xzvf ${pushgateway_pkg}
rm ${pushgateway_pkg}

mv ./${pushgateway_folder}/* ./
rm -r ${pushgateway_folder}

popd

cp ./conf/* ${pushgateway_home}

copy_scripts

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${pushgateway_home}/pushgateway.properties
done

popd