#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

flink_home=${modules_home}/flink

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/flink*
    sed -i "s#{flink_home}#${flink_home}#g" /usr/local/bin/flink*
}

if [ -f "${flink_home}/bin/flink" ]; then
    echo "flink has installed, will only copy scripts"
    copy_scripts
    exit 0
else
    echo "flink has not installed!"
fi

# install flink
mkdir -p ${flink_home}
pushd ${flink_home}

flink_folder=flink-${flink_version}
flink_pkg=flink-${flink_version}-bin-scala_${flink_scala_version}.tgz
flink_pkg_url=${apache_repo}/flink/flink-${flink_version}/${flink_pkg}

# flink_short_version=`echo ${flink_version} | sed -E 's#\.[0-9]+\$##g'`

if [ 'true' == "${COMPILE}" ]; then
    flink_source_folder=flink-${flink_version}
    flink_source_pkg=${flink_source_folder}-src.tgz
    flink_source_pkg_download_url=${apache_repo}/flink/flink-${flink_version}/${flink_source_pkg}
    rm -rf ${flink_source_folder}
    curl -LO ${flink_source_pkg_download_url}
    tar -xzvf ${flink_source_pkg}
    pushd ${flink_source_folder}
    mvn clean package -DskipTests -Drat.skip=true -Denforcer.skip
    mv flink-dist/target/flink-${flink_version}-bin/flink-${flink_version}/* ../
    popd
    rm -r ${flink_source_folder}
    rm ${flink_source_pkg}
else
    curl -LO ${flink_pkg_url}
    tar -xvf ${flink_pkg}
    rm ${flink_pkg}
    mv ./${flink_folder}/* ./
    rm -r ${flink_folder}
fi

# download s3 plugin
mkdir -p plugins/s3
aws_sdk_jar=aws-java-sdk-${aws_sdk_version}.jar
curl -LO ${maven_repo}/com/amazonaws/aws-java-sdk/${aws_sdk_version}/${aws_sdk_jar}
mv ./${aws_sdk_jar} plugins/s3
mv ./opt/flink-s3-fs-hadoop*.jar plugins/s3
popd

# scripts and configs

copy_scripts

cp conf/* ${flink_home}/conf

## local ip
export local_ip=`ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${flink_home}/conf/flink.properties
done

popd