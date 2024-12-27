#!/bin/bash
set -exo pipefail

pushd /tmp

## taglib

rm -rf taglib
git clone ${github_url}/taglib/taglib
pushd taglib
sed -i "s#url = https://github.com#url = ${github_url}#g" .gitmodules
git checkout tags/v${taglib_version}
git submodule update --init
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
make && make install
popd
rm -r taglib

popd