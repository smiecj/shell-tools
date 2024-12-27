#!/bin/bash
set -eo pipefail

jq_folder=jq-jq-${jq_version}
jq_pkg=jq-${jq_version}.tar.gz
jq_download_url=${github_url}/jqlang/jq/archive/refs/tags/${jq_pkg}

if [ -f /usr/local/bin/jq ] || [ -f /usr/bin/jq ]; then
    echo "jq has installed"
    exit 0
fi

pushd /tmp

${INSTALLER} -y install automake libtool

rm -rf ${jq_folder}
curl -LO ${jq_download_url}
tar -xzvf ${jq_pkg}

pushd ${jq_folder}

# git checkout -f tags/jq-${jq_version}
# sed -i "s#= https://github.com#= ${github_url}#g" .gitmodules
# git submodule update --init

autoreconf -i
./configure --disable-maintainer-mode
make
make install

popd

rm -r ${jq_folder}
rm ${jq_pkg}

popd