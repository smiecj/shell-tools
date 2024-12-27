#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

grafana_home=${modules_home}/grafana

copy_scripts() {
    cp ./scripts/* /usr/local/bin/
    chmod +x /usr/local/bin/grafana*
    sed -i "s#{grafana_home}#${grafana_home}#g" /usr/local/bin/grafana*
}

if [ -d "${grafana_home}" ]; then
    echo "grafana has installed, will only copy scripts"
    copy_scripts
    exit 0
fi

## install grafana

rm -rf ${grafana_home} && mkdir -p ${grafana_home}
pushd ${grafana_home}

if [ 'true' == "${COMPILE}" ]; then
    # compile not support direct tar.gz : https://community.grafana.com/t/how-do-i-build-package-grafana-from-source/54484
    # depend nodejs & golang
    grafana_source_folder=grafana-${grafana_version}
    grafana_source_pkg=v${grafana_version}.tar.gz
    grafana_source_pkg_url=${github_url}/grafana/grafana/archive/refs/tags/${grafana_source_pkg}
    
    rm -rf ${grafana_source_folder}
    curl -LO ${grafana_source_pkg_url}
    tar -xzvf ${grafana_source_pkg}
    rm ${grafana_source_pkg}
    pushd ${grafana_source_folder}
    npm -g install yarn typescript
    ## ignore node < v18
    YARN_IGNORE_NODE=1 yarn install
    make build
    cp -r ./conf ${grafana_home}
    cp ${grafana_home}/conf/defaults.ini ${grafana_home}/conf/custom.ini
    mkdir ${grafana_home}/bin
    cp ./bin/linux-${ARCH_SHORT}/* ${grafana_home}/bin
    cp -r ./public ${grafana_home}
    popd
    rm -r ${grafana_source_folder}
else
    grafana_folder=grafana-v${grafana_version}
    grafana_pkg=grafana-enterprise-${grafana_version}.linux-${ARCH_SHORT}.tar.gz
    if [[ ${grafana_repo} =~ .*"dl.grafana.com".* ]];
    then
        # https://dl.grafana.com/enterprise/release/grafana-enterprise-11.3.0.linux-amd64.tar.gz
        grafana_pkg_url=${grafana_repo}/${grafana_pkg}
    else
        grafana_pkg_url=${grafana_repo}/${grafana_version}/${grafana_pkg}
    fi
    rm -f ${grafana_pkg} && wget ${grafana_pkg_url} && tar -xzvf ${grafana_pkg} && rm ${grafana_pkg}
    mv ./${grafana_folder}/* ./ && rm -r ${grafana_folder}
fi

popd

# conf & scripts

cp ./conf/* ${grafana_home}/conf

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${grafana_home}/conf/grafana.properties
done

copy_scripts

popd