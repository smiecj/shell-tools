#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

java_repo_home=${repo_home}/java

# maven
maven_version_tag=`echo ${maven_short_version} | sed 's#\..*##g'`
maven_version=`curl -L ${apache_repo}/maven/maven-${maven_version_tag} | grep ">${maven_short_version}" | sed 's#.*href="##g' | sed "s#/.*##g" | tail -n 1`

maven_pkg=apache-maven-${maven_version}-bin.tar.gz
maven_download_url=${apache_repo}/maven/maven-${maven_version_tag}/${maven_version}/binaries/${maven_pkg}

pushd ${java_home}
curl -L ${maven_download_url} -o ${maven_pkg}
tar -xzvf ${maven_pkg}
rm -f ${maven_pkg}
popd

maven_home=${java_home}/apache-maven-${maven_version}
maven_local_repo=${java_repo_home}/maven
maven_setting=${maven_home}/conf/settings.xml

default_maven_repo_home=.m2
default_maven_repo_path=${default_maven_repo_home}/repository

## vscode maven plugin will use default user ~/.m2 path as repo home
## https://github.com/microsoft/vscode-maven/issues/46#issuecomment-500271983
pushd ${HOME}
rm -rf ${default_maven_repo_path} && mkdir -p ${maven_local_repo} && mkdir -p ${default_maven_repo_home} && ln -s ${maven_local_repo} ${default_maven_repo_path}
rm -f ${default_maven_repo_home}/settings.xml && ln -s ${maven_setting} ${default_maven_repo_home}/settings.xml
popd

# cn mirror
if [ "CN" == "${NET}" ]; then
    sed -i "s#</mirrors>#<mirror>\n<id>cnmaven</id>\n<mirrorOf>central</mirrorOf>\n<name>cn maven</name>\n<url>https://maven.aliyun.com/repository/public</url>\n</mirror>\n</mirrors>#g" ${maven_setting}
fi

java_mark="# java"
echo "export MAVEN_HOME=${maven_home} ${java_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$MAVEN_HOME/bin ${java_mark}" >> /etc/profile

popd