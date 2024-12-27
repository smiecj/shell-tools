#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

navidrome_home=${modules_home}/navidrome
mkdir -p ${navidrome_home}

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/navidrome*
    sed -i "s#{navidrome_home}#${navidrome_home}#g" /usr/local/bin/navidrome*
}

if [ -f "${navidrome_home}/navidrome" ]; then
    echo "navidrome has installed, will only copy scripts"
    copy_scripts
    exit 0
fi

# install taglib: Audio Meta-Data Library
if [ ! -d /usr/include/taglib ] && [ ! -d /usr/local/include/taglib ]; then
    echo "taglib has not installed, will install it first"
    sh ../install-taglib.sh
fi
if [ -d /usr/local/include/taglib ]; then
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig
fi

pushd /tmp

navidrome_version=`echo ${navidrome_tag} | tr -d 'v'`
navidrome_source_folder=navidrome-${navidrome_version}
navidrome_source_pkg=${navidrome_tag}.tar.gz
navidrome_source_pkg_url=${github_url}/navidrome/navidrome/archive/refs/tags/${navidrome_source_pkg}

ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH=amd64
elif [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
fi

navidrome_pkg=navidrome_${navidrome_version}_linux_${ARCH}.tar.gz
navidrome_folder=navidrome_${navidrome_version}
navidrome_pkg_url=${github_url}/navidrome/navidrome/releases/download/v${navidrome_version}/${navidrome_pkg}

if [ 'true' == "${COMPILE}" ]; then
    # compile navidrome

    rm -rf ${navidrome_source_folder}
    curl -LO ${navidrome_source_pkg_url}
    tar -xzvf ${navidrome_source_pkg}

    pushd ${navidrome_source_folder}

    ## https://nova.moe/solve-go-buildvcs
    export GOFLAGS="-buildvcs=false"
    ## fix after start always "Received termination signal" problem
    # sed -i "s#.*SIGHUP.*##g" cmd/signaler_unix.go
    make setup
    make buildall
    cp navidrome ${navidrome_home}
    popd

    rm ${navidrome_source_pkg}
    rm -r ${navidrome_source_folder}

else
    rm -rf ${navidrome_folder}
    mkdir ${navidrome_folder}
    curl -LO ${navidrome_pkg_url}
    tar -xzvf ${navidrome_pkg} -C ${navidrome_folder}

    mv ./${navidrome_folder}/navidrome ${navidrome_home}

    rm -r ${navidrome_folder}
    rm ${navidrome_pkg}
fi

popd

copy_scripts

mkdir -p ${navidrome_home}/conf
cp conf/* ${navidrome_home}/conf

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${navidrome_home}/conf/navidrome.properties
done

popd