#!/bin/bash
set -exo pipefail

pushd /tmp

gcc_pkg=gcc-${gcc_version}.tar.gz
gcc_folder=gcc-${gcc_version}
curl -LO ${gcc_repo}/gcc-${gcc_version}/${gcc_pkg}
tar -xvf gcc-${gcc_version}.tar.gz
pushd ${gcc_folder}
./contrib/download_prerequisites
mkdir -p build
pushd build && ../configure -prefix=${prefix} --enable-checking=release --enable-languages=c,c++ --disable-multilib && make && make install && popd
popd

rm -rf ${gcc_folder} && rm -f ${gcc_pkg}

# gcc_mark="# gcc"
# sed -i "s/.*${gcc_mark}.*//g" /etc/profile
# echo -e "\n${gcc_mark}" >> /etc/profile
# echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH ${gcc_mark}" >> /etc/profile

popd
