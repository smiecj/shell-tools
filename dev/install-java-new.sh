#!/bin/bash
## only install jdk11
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

java_repo_home=${repo_home}/java

arch=`uname -p`
if [ "x86_64" == "${arch}" ]; then
    arch="x64"
fi

# install java
mkdir -p ${java_home} && mkdir -p ${java_repo_home}
jdk_new_version_repo="${jdk_repo}/${jdk_new_version}/jdk/${arch}/linux"
jdk_new_version_pkg=`curl -L ${jdk_new_version_repo} | grep OpenJDK${jdk_new_version}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
jdk_new_version_download_url=${jdk_new_version_repo}/${jdk_new_version_pkg}
jdk_new_version_detail_version=`echo ${jdk_new_version_pkg} | sed "s/.*hotspot_${jdk_new_version}/${jdk_new_version}/g" | sed 's/.tar.*//g' | tr '_' '+'`
jdk_new_version_folder="jdk-${jdk_new_version_detail_version}"
cd ${java_home} && curl -LO ${jdk_new_version_download_url} && tar -xzvf ${jdk_new_version_pkg} && rm ${jdk_new_version_pkg}

# profile
java_mark="# java"
echo -e "\n${java_mark}" >> /etc/profile
echo "export JAVA_HOME=${java_home}/${jdk_new_version_folder} ${java_mark}" >> /etc/profile
