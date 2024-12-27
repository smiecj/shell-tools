#!/bin/bash
set -exo pipefail

# bmon
bmon_repo=${github_url}/tgraf/bmon

pushd /tmp

rm -rf bmon
git clone ${bmon_repo}

if [ "apt" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install automake pkg-config libconfuse-dev libnl-3-dev libnl-route-3-dev
else
    ${INSTALLER} -y install automake libconfuse-devel libnl3-devel
fi

pushd bmon

./autogen.sh
./configure
make
make install

popd

rm -r bmon

popd