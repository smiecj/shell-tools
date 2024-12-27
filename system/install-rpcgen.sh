#!/bin/bash
set -exo pipefail

# https://www.cnblogs.com/silent2012/p/17130917.html

rpcgen_folder=rpcsvc-proto-${rpcgen_version}
rpcgen_pkg=${rpcgen_folder}.tar.xz
rpcgen_download_url=${github_url}/thkukuk/rpcsvc-proto/releases/download/v${rpcgen_version}/${rpcgen_pkg}

pushd /tmp

rm -rf ${rpcgen_folder}
curl -LO ${rpcgen_download_url}
tar -xvf ${rpcgen_pkg}

pushd ${rpcgen_folder}
./configure
make
make install
popd

rm ${rpcgen_pkg}
rm -r ${rpcgen_folder}

popd