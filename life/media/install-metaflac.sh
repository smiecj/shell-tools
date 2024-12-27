#!/bin/bash
set -exo pipefail

cd /tmp

## metaflac
cd /tmp
${INSTALLER} -y install gettext automake libtool pkg-config
if [ "apt" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install libtool-bin
fi
git clone ${github_url}/xiph/flac
cd flac
git checkout tags/${flac_version}
./autogen.sh && ./configure --enable-shared && make && make install
cd .. && rm -r flac