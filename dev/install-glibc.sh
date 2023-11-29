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

# depend: bison, diffutils, python3
${INSTALLER} -y install bison diffutils

# ../configure -prefix=${prefix}
# ../configure --prefix=${prefix} --disable-werror --disable-profile --enable-add-ons --enable-obsolete-nsl --with-headers=/usr/include --with-binutils=/usr/bin

../configure --enable-checking=release --disable-sanity-checks --enable-language=c,c++ --disable-multilib --disable-profile --enable-add-ons --disable-werror --with-headers=/usr/include --with-binutils=/usr/bin

# https://sourceware.org/glibc/wiki/Testing/Builds
sed -i '128i\        && $name ne "nss_test2"' ../scripts/test-installation.pl
## fix "Argument list too long"
env -i PATH="$PATH" make
env -i PATH="$PATH" make install
popd

popd

rm -rf ${glibc_folder} && rm -f ${glibc_pkg}

popd