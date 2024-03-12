#!/bin/bash
set -exo pipefail

pushd /tmp

## ffmpeg
git clone ${github_url}/FFmpeg/FFmpeg
cd FFmpeg
git checkout tags/${ffmpeg_version}
${INSTALLER} -y install diffutils
./configure --prefix=/usr --disable-x86asm && make && make install
cd .. && rm -r FFmpeg

popd