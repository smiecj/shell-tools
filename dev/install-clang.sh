#!/bin/bash
set -exo pipefail

pushd /tmp

# https://clang.llvm.org/get_started.html

llvm_project_folder=llvm-project-llvmorg-${llvm_version}
llvm_project_pkg=llvmorg-${llvm_version}.tar.gz
llvm_project_download_url=${github_url}/llvm/llvm-project/archive/refs/tags/${llvm_project_pkg}

# install clang
rm -rf ${llvm_project_folder}
curl -LO ${llvm_project_download_url}
tar -xzvf ${llvm_project_pkg}

pushd ${llvm_project_folder}

mkdir build
pushd build
# for higher version cmake
export PATH=/usr/local/bin:$PATH
cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
make && make install
popd

popd

rm ${llvm_project_pkg}
rm -r ${llvm_project_folder}