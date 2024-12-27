#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

code_server_home=${modules_home}/codeserver

copy_scripts() {
    cp ./scripts/* /usr/local/bin/
    chmod +x /usr/local/bin/codeserver*
    sed -i "s#{code_server_home}#${code_server_home}#g" /usr/local/bin/codeserver*
}

if [ -d "${code_server_home}" ]; then
    echo "code server has installed, will only copy scripts"
    copy_scripts
    exit 0
fi

mkdir -p ${code_server_home}
pushd ${code_server_home}

code_server_folder=code-server-${code_server_version}-linux-${ARCH_SHORT}
code_server_pkg=${code_server_folder}.tar.gz
# code_server_pkg=${code_server_folder}.zip
curl -LO ${github_url}/coder/code-server/releases/download/v${code_server_version}/${code_server_pkg}

tar -xzvf ${code_server_pkg} || true
# unzip ${code_server_pkg}
mv ./${code_server_folder}/* ./
rm ${code_server_pkg}
rm -r ${code_server_folder}

echo """bind-addr: 0.0.0.0:${code_server_port}
auth: password
password: code_server
cert: false
""" > config.yaml

popd

copy_scripts

popd

## profile
# code_server_mark="# code-server"
# sed -i "s/.*${code_server_mark}.*//g" /etc/profile
# echo -e "\n${code_server_mark}" >> /etc/profile
# echo "export CODE_SERVER_HOME=${code_server_home} ${code_server_mark}" >> /etc/profile
# echo "export PATH=\$PATH:\$CODE_SERVER_HOME/bin ${code_server_mark}" >> /etc/profile