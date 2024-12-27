#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

kafka_home=${modules_home}/kafka

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/kafka*
    sed -i "s#{kafka_home}#${kafka_home}#g" /usr/local/bin/kafka*
}

if [ -d "${kafka_home}" ]; then
    echo "kafka has installed, will only copy scripts"
    copy_scripts
    exit 0
else
    echo "kafka has not installed!"
fi

kafka_pkg_folder=kafka_${kafka_scala_version}-${kafka_version}
kafka_pkg=${kafka_pkg_folder}.tgz
kafka_pkg_url=${apache_repo}/kafka/${kafka_version}/${kafka_pkg}

mkdir -p ${kafka_home}

pushd ${kafka_home}

if [ 'true' == "${COMPILE}" ]; then

    kafka_source_folder=kafka-${kafka_version}-src
    kafka_source_pkg=${kafka_source_folder}.tgz
    kafka_source_pkg_url=${apache_repo}/kafka/${kafka_version}/${kafka_source_pkg}

    rm -rf ${kafka_source_folder}
    curl -LO ${kafka_source_pkg_url}
    tar -xvf ${kafka_source_pkg}

    pushd ${kafka_source_folder}
    sed -i "s#https\\://services.gradle.org/distributions#${gradle_repo}#g" ./gradle/wrapper/gradle-wrapper.properties
    ./gradlew releaseTarGz -PscalaVersion=${kafka_scala_version} -x test > test.log 2>&1 &
    mv ./core/build/distributions/${kafka_pkg} ${kafka_home}/
    popd

    rm -r ${kafka_source_folder}
else
    curl -LO ${kafka_pkg_url}
fi

tar -xzvf ${kafka_pkg}
rm ${kafka_pkg}
mv ./${kafka_pkg_folder}/* ./
rm -r ${kafka_pkg_folder}

popd

# scripts and configs

copy_scripts

cp config/* ${kafka_home}/config

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${kafka_home}/config/kafka.properties
done

popd