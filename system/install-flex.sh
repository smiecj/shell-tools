#!/bin/bash
set -exo pipefail

flex_folder=flex-${flex_version}
flex_pkg=v${flex_version}.tar.gz
flex_download_url=${github_url}/westes/flex/archive/refs/tags/${flex_pkg}

pushd /tmp

${INSTALLER} -y install libtool
if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install libtool bison flex gettext-devel
    # makeinfo: make texinfo
    # help2man: make help2man
else
    ${INSTALLER} -y install libtool bison flex texinfo autopoint help2man
fi

rm -rf ${flex_folder}
curl -LO ${flex_download_url}
tar -xzvf ${flex_pkg}

pushd ${flex_folder}
./autogen.sh
./configure
make
make install
popd

rm ${flex_pkg}
rm -r ${flex_folder}

popd