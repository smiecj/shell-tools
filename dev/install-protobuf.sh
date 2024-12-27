#!/bin/bash
set -exo pipefail

protobuf_home=${modules_home}/protobuf

pushd /tmp

rm -rf protobuf
git clone ${github_url}/protocolbuffers/protobuf

pushd protobuf

git checkout tags/${protobuf_tag}

# https://github.com/protocolbuffers/protobuf/blob/main/cmake/README.md#linux-builds
git submodule update --init --recursive
# cmake . -DCMAKE_INSTALL_PREFIX=${protobuf_home}

if [ -f "/usr/local/bin/gcc" ]; then
    libc_found=`find /usr/local -name 'libc.so' | wc -l`
    libstdc_found=`find /usr/local -name 'libstdc++.so' | wc -l`
    if [ $libc_found -gt 0 ] || [ $libstdc_found -gt 0 ]; then
        export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
    fi
fi

cmake .
cmake --build .
make && make install

# old version
# ./autogen.sh
# ./configure --prefix=${protobuf_home}
# make && make install
# ldconfig

popd

rm -r protobuf

popd