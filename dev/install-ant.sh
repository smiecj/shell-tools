#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

# ant
ant_repo=${apache_repo}/ant/binaries
ant_pkg=`curl -L ${ant_repo} | grep apache-ant-${ant_short_version} | grep "tar.gz" | sed 's#.*href="##g' | sed 's#".*##g' | sed -n 1p`
ant_version=`echo ${ant_pkg} | sed 's#apache-ant-##g' | sed 's#-.*##g'`
ant_folder=apache-ant-${ant_version}
pushd ${java_home}
curl -LO ${ant_repo}/${ant_pkg}
tar -xzvf ${ant_pkg}
rm ${ant_pkg}
popd

java_mark="# java"
echo "export ANT_HOME=$java_home/$ant_folder ${java_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$ANT_HOME/bin ${java_mark}" >> /etc/profile
popd