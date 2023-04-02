#!/bin/bash
set -exo pipefail

pushd /tmp

cmake_folder=cmake-${cmake_long_version}
cmake_pkg=${cmake_folder}.tar.gz

curl -LO https://cmake.org/files/v${cmake_short_version}/${cmake_pkg}

tar -xzvf ${cmake_pkg}
pushd ${cmake_folder}

./bootstrap
gmake
gmake install

popd

rm ${cmake_pkg}
rm -r ${cmake_folder}

cmake_mark="# cmake"
sed -i "s/.*${cmake_mark}.*//g" /etc/profile
echo -e "\n${cmake_mark}" >> /etc/profile
echo "export CMAKE_ROOT=/usr/local/share/cmake-${cmake_long_version} ${cmake_mark}" >> /etc/profile

popd