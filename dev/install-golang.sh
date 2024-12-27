#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

go_home=${modules_home}/golang
go_repo_home=${repo_home}/go

rm -rf ${go_home} && mkdir -p ${go_home} && mkdir -p ${go_repo_home}
go_pkg=go${go_version}.linux-${ARCH_SHORT}.tar.gz
go_pkg_download_url=${go_pkg_repo}/${go_pkg}
cd ${go_home} && curl -LO ${go_pkg_download_url} && tar -xzvf ${go_pkg} && rm ${go_pkg}
mv go/* ./ && rm -r go

## profile
go_mark="# go"
sed -i "s/.*${go_mark}.*//g" /etc/profile
echo -e "\n${go_mark}" >> /etc/profile
echo "export GOROOT=${go_home} ${go_mark}" >> /etc/profile
echo "export GOPATH=$go_repo_home ${go_mark}" >> /etc/profile
echo "export GOPROXY=$go_proxy ${go_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin ${go_mark}" >> /etc/profile

## config: goproxy (if needed)
set +o pipefail
source /etc/profile && go env -w GOPROXY=${go_proxy}