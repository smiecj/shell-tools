#!/bin/bash
set -exo pipefail

pushd /tmp

glibc_pkg=glibc-${glibc_version}.tar.gz
glibc_folder=glibc-${glibc_version}
curl -LO ${glibc_repo}/${glibc_pkg}
tar -xzvf ${glibc_pkg}
pushd ${glibc_folder}
../configure -prefix=/
make && make install
popd

rm -rf ${glibc_folder} && rm -f ${glibc_pkg}

popd