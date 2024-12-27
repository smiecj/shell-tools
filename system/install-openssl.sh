#!/bin/bash
set -exo pipefail

if [ "${openssl_version}" \< "3.0.0" ]; then
    openssl_version=`echo ${openssl_version} | sed 's#\.#_#g'`

    openssl_folder=openssl-OpenSSL_${openssl_version}
    openssl_pkg=OpenSSL_${openssl_version}.tar.gz
else
    openssl_folder=openssl-openssl-${openssl_version}
    openssl_pkg=openssl-${openssl_version}.tar.gz

    if [ "yum" == "${INSTALLER}" ]; then
        ${INSTALLER} -y install perl-IPC-Cmd perl-Pod-Html
    fi
fi

openssl_download_url=${github_url}/openssl/openssl/archive/refs/tags/${openssl_pkg}

pushd /tmp

rm -rf ${openssl_folder}
curl -LO ${openssl_download_url}
tar -xzvf ${openssl_pkg}

pushd ${openssl_folder}
./config
make
make install
popd

rm ${openssl_pkg}
rm -rf ${openssl_folder}

# cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl -DOPENSSL_LIBRARIES=/usr/local/opt/openssl/lib

# OPENSSL_ROOT_DIR=D:/softwares/visualStudio/openssl-0.9.8k_WIN32
# OPENSSL_INCLUDE_DIR=D:/softwares/visualStudio/openssl-0.9.8k_WIN32/include
# OPENSSL_LIBRARIES=D:/softwares/visualStudio/openssl-0.9.8k_WIN32/lib

popd