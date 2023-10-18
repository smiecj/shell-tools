#!/bin/bash
set -exo pipefail

code_server_home=${modules_home}/codeserver

system_arch=`uname -p`

arch=`uname -p`
if [ "x86_64" == "${arch}" ]; then
    arch="amd64"
elif [ "aarch64" == "${arch}" ]; then
    arch="arm64"
fi

pushd /tmp

code_server_folder=code-server-${code_server_version}-linux-${arch}
code_server_pkg=${code_server_folder}.tar.gz
curl -LO ${github_url}/coder/code-server/releases/download/v${code_server_version}/${code_server_pkg}
mkdir -p ${code_server_home}
mv ${code_server_pkg} ${code_server_home}

popd

push ${module_home}

tar -xzvf ${code_server_pkg}
rm ${code_server_pkg}

popd

## profile
code_server_mark="# code-server"
sed -i "s/.*${code_server_mark}.*//g" /etc/profile
echo -e "\n${code_server_mark}" >> /etc/profile
echo "export CODE_SERVER_HOME=${code_server_home}/${code_server_folder} ${code_server_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$CODE_SERVER_HOME/bin ${code_server_mark}" >> /etc/profile
