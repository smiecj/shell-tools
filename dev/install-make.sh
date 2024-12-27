#!/bin/bash
set -exo pipefail

pushd /tmp

make_folder=make-${make_version}
make_pkg=${make_folder}.tar.gz

pushd /tmp

curl -LO ${gnu_repo}/make/${make_pkg}
tar -xzvf ${make_pkg}
rm ${make_pkg}
pushd ${make_folder}
mkdir build
pushd build
../configure --prefix=/usr
make && make install
popd
popd

rm -r ${make_folder}

popd