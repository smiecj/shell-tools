#!/bin/bash
set -exo pipefail

binutils_folder=binutils-${binutils_version}
binutils_pkg=${binutils_folder}.tar.gz
binutils_download_url=${gnu_repo}/binutils/${binutils_pkg}

if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install gmp-devel
else
    ${INSTALLER} -y install libgmp-dev
fi

pushd /tmp

rm -rf ${binutils_folder}
curl -LO ${binutils_download_url}
tar -xzvf ${binutils_pkg}

pushd ${binutils_folder}
./configure --prefix=/usr
make
make install
popd

rm ${binutils_pkg}
rm -r ${binutils_folder}

popd