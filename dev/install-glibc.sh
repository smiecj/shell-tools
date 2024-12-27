#!/bin/bash
set -exo pipefail

# https://blog.csdn.net/m0_37814112/article/details/131515147

pushd /tmp

glibc_pkg=glibc-${glibc_version}.tar.gz
glibc_folder=glibc-${glibc_version}
curl -LO ${gnu_repo}/glibc/${glibc_pkg}
rm -rf ${glibc_folder}
tar -xzvf ${glibc_pkg}

pushd ${glibc_folder}
mkdir -p build

pushd build

# depend: bison, diffutils, python3
${INSTALLER} -y install bison diffutils

if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install libcap-devel audit-libs-devel gd-devel
    ${INSTALLER} -y install glibc-static || true
    ${INSTALLER} --enablerepo=powertools -y install glibc-static || true
    
    python3_has_installed=`python3 -v || true`
    if [ -n "${nodejs_has_installed}" ]; then
        echo "nodejs has installed!"
        exit 0
    fi

else
    ${INSTALLER} -y install libcap-dev
fi

# ../configure -prefix=${PREFIX}
# ../configure --prefix=${PREFIX} --disable-werror --disable-profile --enable-add-ons --enable-obsolete-nsl --with-headers=/usr/include --with-binutils=/usr/bin

## 临时注释
## ../configure --enable-checking=release --disable-sanity-checks --enable-language=c,c++ --disable-multilib --disable-profile --enable-add-ons --disable-werror --with-headers=/usr/include --with-binutils=/usr/bin
## ../configure --prefix=/usr/local --disable-werror --disable-sanity-checks
# https://sourceware.org/glibc/wiki/Testing/Builds
# sed -i '128i\        && $name ne "nss_test2"' ../scripts/test-installation.pl
## fix "Argument list too long"
# env -i PATH="$PATH" make
# env -i PATH="$PATH" make install

# gcc
if [ -f /usr/local/bin/gcc ]; then
    export PATH=/usr/local/bin:$PATH
fi

# ../configure --prefix=/usr/local/glibc-${glibc_version} --disable-werror
# glibc not allow to install at /usr
# ../configure --prefix=/usr/local/glibc-${glibc_version} --disable-werror

export LD_LIBRARY_PATH=""
../configure --prefix=/usr/local --disable-werror --disable-sanity-checks

make
env -i PATH="$PATH" make install
# ldconfig

popd

popd

rm -rf ${glibc_folder} && rm -f ${glibc_pkg}

popd