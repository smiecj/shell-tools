#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

npm_home=/usr/nodejs
npm_repo_home=${repo_home}/nodejs

# installed check
nodejs_has_installed=`npm -v || true`
if [ -n "${nodejs_has_installed}" ]; then
    echo "nodejs has installed!"
    exit 0
fi

# install
system_arch=`uname -p`
if [ "x86_64" == "${system_arch}" ]; then arch="x64"; else arch="arm64"; fi
npm_folder=node-${nodejs_version}-linux-${arch}
npm_pkg=${npm_folder}.tar.gz
npm_download_url=${nodejs_repo}/${nodejs_version}/${npm_pkg}
mkdir -p ${npm_home} && mkdir -p ${npm_repo_home}
cd ${npm_home} && curl -LO ${npm_download_url} && tar -xzvf ${npm_pkg} && rm -f ${npm_pkg}
mv ${npm_folder}/* ./ && rm -r ${npm_folder}

# profile
nodejs_mark="# nodejs"
sed -i "s/.*${nodejs_mark}.*//g" /etc/profile
echo -e "\n${nodejs_mark}" >> /etc/profile
echo "export NODE_HOME=${npm_home} ${nodejs_mark}" >> /etc/profile
echo "export NODE_REPO=${npm_repo_home}/global_modules ${nodejs_mark}" >> /etc/profile 
echo "export PATH=\$PATH:\$NODE_HOME/bin:\$NODE_REPO/bin ${nodejs_mark}" >> /etc/profile

echo "prefix = ${npm_repo_home}/global_modules" >> $HOME/.npmrc
echo "cache = ${npm_repo_home}/cache" >> $HOME/.npmrc
echo "registry = ${npm_mirror}" >> $HOME/.npmrc
mkdir -p ${npm_repo_home}/global_modules
mkdir -p ${npm_repo_home}/cache