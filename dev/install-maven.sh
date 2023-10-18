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

# maven
maven_version_tag=`echo ${maven_short_version} | sed 's#\..*##g'`
maven_version=`curl -L ${apache_repo}/maven/maven-${maven_version_tag} | grep ">${maven_short_version}" | sed 's#.*href="##g' | sed "s#/.*##g"`
echo "[test] maven version: $maven_version"

maven_pkg=apache-maven-${maven_version}-bin.tar.gz && \
maven_download_url=${apache_repo}/maven/maven-3/${maven_version}/binaries/${maven_pkg} && \
cd ${java_home} && source /etc/profile && curl -L ${maven_download_url} -o ${maven_pkg} && \
tar -xzvf ${maven_pkg} && \
rm -f ${maven_pkg} && \
maven_home=/usr/java/apache-maven-${maven_version} && \
maven_local_repo=${java_repo_home}/maven && \
maven_setting=${maven_home}/conf/settings.xml && \

default_maven_repo_home=.m2 && \
default_maven_repo_path=${default_maven_repo_home}/repository && \

## vscode maven plugin will use default user ~/.m2 path as repo home
## https://github.com/microsoft/vscode-maven/issues/46#issuecomment-500271983
cd ~ && rm -rf ${default_maven_repo_path} && mkdir -p ${maven_local_repo} && mkdir -p ${default_maven_repo_home} && ln -s ${maven_local_repo} ${default_maven_repo_path} && \
cd ~ && rm -f ${default_maven_repo_home}/settings.xml && ln -s ${maven_setting} ${default_maven_repo_home}/settings.xml

java_mark="# java"
echo "export MAVEN_HOME=${maven_home} ${java_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$MAVEN_HOME/bin ${java_mark}" >> /etc/profile