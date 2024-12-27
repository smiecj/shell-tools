#!/bin/bash
set -exo pipefail

# cmake_folder=cmake-${cmake_long_version}
# cmake_pkg=${cmake_folder}.tar.gz
# curl -LO https://cmake.org/files/v${cmake_short_version}/${cmake_pkg}
# tar -xzvf ${cmake_pkg}
# pushd ${cmake_folder}

cmake_source_folder=cmake-${cmake_long_version}
cmake_source_pkg=${cmake_source_folder}.tar.gz
cmake_source_pkg_url=${github_url}/Kitware/CMake/releases/download/v${cmake_long_version}/${cmake_source_pkg}

pushd /tmp

if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install gcc-c++ openssl-devel
else
    ${INSTALLER} -y install g++ libssl-dev
fi

if [ -f "/usr/local/bin/gcc" ]; then
    export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
fi

rm -rf ${cmake_source_folder}
curl -LO ${cmake_source_pkg_url}
tar -xzvf ${cmake_source_pkg}
rm ${cmake_source_pkg}

pushd ${cmake_source_folder}

./bootstrap
make
make install

popd

rm -r ${cmake_source_folder}

# cmake_mark="# cmake"
# sed -i "s/.*${cmake_mark}.*//g" /etc/profile
# echo -e "\n${cmake_mark}" >> /etc/profile
# echo "export CMAKE_ROOT=/usr/local/share/cmake-${cmake_long_version} ${cmake_mark}" >> /etc/profile

popd