#!/bin/bash
set -exo pipefail

pushd /tmp

git clone ${github_url}/GNOME/glib

pushd glib
git checkout tags/

rm -rf glog

pushd glog

./autogen.sh
./configure
make
make install

popd

rm -r glog

popd