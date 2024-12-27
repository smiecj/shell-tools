#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

icecast_home=${modules_home}/icecast

mkdir -p ${icecast_home}

# system dependency

if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install automake libtool gettext-devel libogg-devel
else
    ${INSTALLER} -y install automake libtool gettext libxml2-dev libconfig-dev libogg-dev libxslt1-dev
fi

# taglib

if [ ! -d /usr/include/taglib ] && [ ! -d /usr/local/include/taglib ]; then
    echo "taglib has not installed, will install it first"
    sh ../install-taglib.sh
fi
if [ -d /usr/local/include/taglib ]; then
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig
fi

# check

if [ ! -f /usr/include/check.h ] && [ ! -f /usr/local/include/check.h ]; then

    check_folder=check-${check_version}
    check_pkg=${check_folder}.tar.gz
    check_download_url=${github_url}/libcheck/check/releases/download/${check_version}/${check_pkg}

    rm -rf ${check_folder}
    curl -LO ${check_download_url}
    tar -xzvf ${check_pkg}

    pushd ${check_folder}
    ./configure --prefix=${PREFIX}
    make
    make install
    popd

    rm ${check_pkg}
    rm -r ${check_folder}

fi

# libshout

if [ ! -d /usr/include/shout ] && [ ! -d /usr/local/include/shout ]; then

    rm -rf icecast-libshout
    git clone https://gitlab.xiph.org/xiph/icecast-libshout

    pushd icecast-libshout

    git submodule update --init --recursive

    ./autogen.sh
    ./configure --prefix=${PREFIX}
    make
    make install

    popd
    rm -r icecast-libshout
fi

# ezstream
rm -rf ezstream
git clone https://gitlab.xiph.org/xiph/ezstream

pushd ezstream

./autogen.sh
./configure --prefix=${PREFIX}
make
make install

popd

rm -r ezstream

# vorbis

if [ ! -f /usr/include/vorbis ] && [ ! -d /usr/local/include/vorbis ]; then

    rm -rf vorbis
    git clone https://github.com/xiph/vorbis

    pushd vorbis

    ./autogen.sh
    ./configure --prefix=${PREFIX}
    make
    make install

    popd
    rm -r vorbis

fi

# icecast

rm -rf icecast-server
# git clone ${github_url}/xiph/Icecast-Server
git clone https://gitlab.xiph.org/xiph/icecast-server

pushd icecast-server

git submodule update --init --recursive

./autogen.sh
./configure --prefix=${PREFIX}
make
make install
popd

rm -r icecast-server

cp scripts/* /usr/local/bin
chmod +x /usr/local/bin/icecast*
sed -i "s#{icecast_home}#${icecast_home}#g" /usr/local/bin/icecast*

cp conf/* ${icecast_home}

export icecast_bin=${PREFIX}/bin/icecast
export icecast_base_dir=${PREFIX}/share/icecast

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${icecast_home}/icecast.properties
done

popd
