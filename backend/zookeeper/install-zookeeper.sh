#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

zookeeper_home=${modules_home}/zookeeper

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/zookeeper*
    sed -i "s#{zookeeper_home}#${zookeeper_home}#g" /usr/local/bin/zookeeper*
}

if [ -f "${zookeeper_home}/bin/zkCli.sh" ]; then
    echo "zookeeper has installed, will only copy scripts"
    copy_scripts
    exit 0
else
    echo "zookeeper has not installed!"
fi

zookeeper_pkg_folder=apache-zookeeper-${zookeeper_version}-bin
zookeeper_pkg=${zookeeper_pkg_folder}.tar.gz
zookeeper_pkg_url=${apache_repo}/zookeeper/zookeeper-${zookeeper_version}/${zookeeper_pkg}

mkdir -p ${zookeeper_home}

# download zookeeper

pushd ${zookeeper_home}

if [ 'true' == "${COMPILE}" ]; then
    zookeeper_source_folder=zookeeper-release-${zookeeper_version}
    zookeeper_source_pkg=release-${zookeeper_version}.tar.gz
    zookeeper_source_pkg_download_url=${github_url}/apache/zookeeper/archive/refs/tags/${zookeeper_source_pkg}

    rm -rf ${zookeeper_source_folder}
    curl -LO ${zookeeper_source_pkg_download_url}
    tar -xzvf ${zookeeper_source_pkg}
    rm ${zookeeper_source_pkg}

    pushd ${zookeeper_source_folder}
    mvn clean install -DskipTests
    mv zookeeper-assembly/target/${zookeeper_pkg} ${zookeeper_home}/
    popd
    
    rm -r ${zookeeper_source_folder}
else
    curl -LO ${zookeeper_pkg_url}
fi

tar -xzvf ${zookeeper_pkg}
rm ${zookeeper_pkg}
mv ./${zookeeper_pkg_folder}/* ./ && rm -r ${zookeeper_pkg_folder}

popd

# copy scripts and configs

cp conf/* ${zookeeper_home}/conf

# cp -r s6/* /etc/s6-overlay/s6-rc.d

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${zookeeper_home}/conf/zookeeper.properties
done

copy_scripts

popd