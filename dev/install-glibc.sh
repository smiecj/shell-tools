#!/bin/bash
set -exo pipefail

pushd /tmp

glibc_pkg=glibc-${glibc_version}.tar.gz
glibc_folder=glibc-${glibc_version}
curl -LO ${glibc_repo}/${glibc_pkg}
rm -rf ${glibc_folder}
tar -xzvf ${glibc_pkg}
pushd ${glibc_folder}
mkdir -p build
pushd build
# ../configure -prefix=${prefix}
# ../configure --prefix=${prefix} --disable-werror --disable-profile --enable-add-ons --enable-obsolete-nsl --with-headers=/usr/include --with-binutils=/usr/bin
../configure -prefix=/usr
# https://sourceware.org/glibc/wiki/Testing/Builds
sed -i '128i\        && $name ne "nss_test2"' ../scripts/test-installation.pl
make && make install
popd
popd

rm -rf ${glibc_folder} && rm -f ${glibc_pkg}

popd