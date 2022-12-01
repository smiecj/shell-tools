#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

java_home=/usr/java
java_repo_home=${repo_home}/java

arch=`uname -p`
if [ "x86_64" == "${arch}" ]; then
    arch="x64"
fi

# install java
mkdir -p ${java_home} && mkdir -p ${java_repo_home} && \
jdk_new_version_repo="${jdk_repo}/${jdk_new_version}/jdk/${arch}/linux" && \
jdk_new_version_pkg=`curl -L ${jdk_new_version_repo} | grep OpenJDK${jdk_new_version}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'` && \
jdk_new_version_download_url=${jdk_new_version_repo}/${jdk_new_version_pkg} && \
jdk_new_version_detail_version=`echo ${jdk_new_version_pkg} | sed "s/.*hotspot_${jdk_new_version}/${jdk_new_version}/g" | sed 's/.tar.*//g' | tr '_' '+'` && \
jdk_new_version_folder="jdk-${jdk_new_version_detail_version}" && \

jdk_old_version_repo="${jdk_repo}/8/jdk/${arch}/linux" && \
jdk_old_version_pkg=`curl -L ${jdk_old_version_repo} | grep OpenJDK${jdk_old_version}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'` && \
jdk_old_version_download_url=${jdk_old_version_repo}/${jdk_old_version_pkg} && \
jdk_old_version_detail_version=`echo ${jdk_old_version_pkg} | sed "s/.*hotspot_${jdk_old_version}/${jdk_old_version}/g" | sed 's/.tar.*//g' | sed 's/b/-b/g'` && \
jdk_old_version_folder="jdk${jdk_old_version_detail_version}" && \
cd ${java_home} && curl -LO ${jdk_new_version_download_url} && tar -xzvf ${jdk_new_version_pkg} && rm ${jdk_new_version_pkg} && \
curl -LO ${jdk_old_version_download_url} && tar -xzvf ${jdk_old_version_pkg} && rm ${jdk_old_version_pkg}

# profile
java_mark="# java"
sed -i "s/.*${java_mark}.*//g" /etc/profile
echo -e "\n${java_mark}" >> /etc/profile
echo "export JAVA_HOME=${java_home}/${jdk_old_version_folder} ${java_mark}" >> /etc/profile
echo "export JRE_HOME=\$JAVA_HOME/jre ${java_mark}" >> /etc/profile
echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib ${java_mark}" >> /etc/profile
echo "export JDK_HOME=${java_home}/${jdk_new_version_folder} ${java_mark}" >> /etc/profile

# maven
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
cd ~ && rm -rf ${default_maven_repo_path} && mkdir -p ${maven_repo} && mkdir -p ${default_maven_repo_home} && ln -s ${maven_repo} ${default_maven_repo_path} && \
cd ~ && rm -f ${default_maven_repo_home}/settings.xml && ln -s ${maven_setting} ${default_maven_repo_home}/settings.xml

# gradle
gradle_pkg=gradle-${gradle_version}-bin.zip && \
gradle_download_url=https://downloads.gradle-dn.com/distributions/${gradle_pkg} && \
cd ${java_home} && source /etc/profile && curl -L ${gradle_download_url} -o ${gradle_pkg} && \
unzip ${gradle_pkg} && rm -f ${gradle_pkg}

# ant
ant_repo=${apache_repo}/ant/binaries && \
ant_pkg=apache-ant-${ant_version}-bin.tar.gz && \
ant_folder=apache-ant-${ant_version} && \
cd /usr/java && curl -LO ${ant_repo}/${ant_pkg} && \
tar -xzvf ${ant_pkg} && rm ${ant_pkg}

# other profile
echo "export MAVEN_HOME=$maven_home ${java_mark}" >> /etc/profile
echo "export GRADLE_HOME=/usr/java/gradle-$gradle_version ${java_mark}" >> /etc/profile
echo "export GRADLE_USER_HOME=$java_repo_home/gradle ${java_mark}" >> /etc/profile
echo "export ANT_HOME=$java_home/$ant_folder ${java_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin:\$MAVEN_HOME/bin:\$GRADLE_HOME/bin:\$ANT_HOME/bin ${java_mark}" >> /etc/profile