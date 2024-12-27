#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

java_repo_home=${repo_home}/java

# gradle
gradle_pkg=gradle-${gradle_version}-bin.zip
gradle_repo=`echo ${gradle_repo} | sed 's#\\\\##g'`
gradle_download_url=${gradle_repo}/${gradle_pkg}
cd ${java_home} && source /etc/profile && curl -L ${gradle_download_url} -o ${gradle_pkg}
unzip ${gradle_pkg} && rm -f ${gradle_pkg}

java_mark="# java"
echo "export GRADLE_HOME=/usr/java/gradle-$gradle_version ${java_mark}" >> /etc/profile
echo "export GRADLE_USER_HOME=$java_repo_home/gradle ${java_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$GRADLE_HOME/bin ${java_mark}" >> /etc/profile

popd