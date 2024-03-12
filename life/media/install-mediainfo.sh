#!/bin/bash
set -exo pipefail

cd /tmp

## mediainfo
${INSTALLER} -y install libtool diffutils libzen libzen-devel
git clone ${github_url}/MediaArea/MediaInfoLib
cd MediaInfoLib
git checkout tags/${mediainfolib_version}
cd Project/GNU/Library
./autogen.sh && ./configure --enable-shared && make && make install
cd /tmp

git clone ${github_url}/MediaArea/MediaInfo && \
cd MediaInfo/Project/GNU/CLI && \
./autogen.sh && ./configure --enable-shared && make && make install

cd /tmp && rm -r MediaInfo && rm -r MediaInfoLib