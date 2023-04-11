#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

if [ -f ${HOME}/.cargo/bin/rustc ]; then
    echo "rust has installed"
    exit 0
fi

pushd /tmp

curl --proto '=https' --tlsv1.2 -sSf ${rust_init_script} | sh -s -- -y
source ~/.profile
rustc -V

popd

if [ -n "${cargo_config}" ]; then
    mkdir -p ${HOME}/.cargo
    cp ./cargo/${cargo_config} ${HOME}/.cargo/config
fi

popd