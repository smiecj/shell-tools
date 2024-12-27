#!/bin/bash
set -exo pipefail

glog_folder=glog-${glog_version}
glog_pkg=v${glog_version}.tar.gz
glog_download_url=${github_url}/google/glog/archive/refs/tags/${glog_pkg}

pushd /tmp

rm -rf ${glog_folder}
curl -LO ${glog_download_url}
tar -xzvf ${glog_pkg}

pushd glog

# https://google.github.io/glog/stable/build/#cmake
# cmake >= 3.22
cmake -S . -B build -G "Unix Makefiles"
cmake --build build
cmake --build build --target install

popd

rm -r ${glog_version}
rm ${glog_pkg}

popd