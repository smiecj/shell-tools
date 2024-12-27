#!/bin/bash
set -exo pipefail

pushd /tmp

${INSTALLER} -y install automake libtool

# re2c: Lexer generator for C, C++, Go and Rust.

if [ ! -f /usr/local/bin/re2c ]; then
    re2c_folder=re2c-${re2c_tag}
    re2c_pkg=${re2c_tag}.tar.gz
    re2c_download_url=${github_url}/skvadrik/re2c/archive/refs/tags/${re2c_pkg}

    rm -rf ${re2c_folder}
    curl -LO ${re2c_download_url}
    tar -xzvf ${re2c_pkg}

    pushd ${re2c_folder}
    autoreconf -i -W all
    ./configure
    make
    make install
    popd

    rm ${re2c_pkg}
    rm -r ${re2c_folder}
else
    echo "re2c has installed"
fi

ninja_tag=v${ninja_version}
ninja_folde
r=ninja-${ninja_version}
ninja_pkg=${ninja_tag}.tar.gz
ninja_download_url=${github_url}/ninja-build/ninja/archive/refs/tags/${ninja_pkg}

rm -rf ${ninja_folder}
curl -LO ${ninja_download_url}
tar -xzvf ${ninja_pkg}

pushd ${ninja_folder}
./configure.py --bootstrap
mv ninja /usr/local/bin/
popd

rm ${ninja_pkg}
rm -r ${ninja_folder}

popd