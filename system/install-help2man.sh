#!/bin/bash
set -exo pipefail

help2man_folder=help2man-${help2man_version}
help2man_pkg=v${help2man_version}-${help2man_version}.tar.xz
help2man_download_url=${gnu_repo}/help2man/${help2man_pkg}

pushd /tmp

rm -rf ${help2man_folder}
curl -LO ${help2man_download_url}
tar -xzvf ${help2man_pkg}

pushd ${help2man_folder}
./configure
make
make install
popd

rm ${help2man_pkg}
rm -r ${help2man_folder}

popd