#!/bin/bash
set -exo pipefail

texinfo_folder=texinfo-${texinfo_version}
texinfo_pkg=${texinfo_folder}.tar.gz
texinfo_download_url=${gnu_repo}/texinfo/${texinfo_pkg}

pushd /tmp

rm -rf ${texinfo_folder}
curl -LO ${texinfo_download_url}
tar -xzvf ${texinfo_pkg}

pushd ${texinfo_folder}
./configure
make
make install
popd

rm ${texinfo_pkg}
rm -r ${texinfo_folder}

popd