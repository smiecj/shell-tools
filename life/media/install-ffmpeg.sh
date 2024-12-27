#!/bin/bash
set -eo pipefail

pushd /tmp

if [ "/usr/local" == "${PREFIX}" ]; then
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig
fi

## libmp3lame
if [ ! -f "${PREFIX}/lib/libmp3lame.so" ]; then
    rm -rf libmp3lame
    git clone ${github_url}/gypified/libmp3lame
    pushd libmp3lame
    build_param=""
    if [ "$ARCH" == "aarch64" ]; then
        build_param="--build=aarch64-unknown-linux-gnu"
    fi
    ./configure --prefix=${PREFIX} ${build_param}
    make
    make install
    popd
    rm -r libmp3lame
fi

## libopus
if [ ! -d "${PREFIX}/include/opus" ]; then
    libopus_folder=opus-${opus_version}
    libopus_pkg=${libopus_folder}.tar.gz
    libopus_download_url=${github_url}/xiph/opus/releases/download/v${opus_version}/${libopus_pkg}

    rm -rf ${libopus_folder}
    curl -LO ${libopus_download_url}
    tar -xzvf ${libopus_pkg}

    pushd ${libopus_folder}
    ./configure --prefix=${PREFIX}
    make
    make install
    popd
    rm ${libopus_pkg}
    rm -r ${libopus_folder}
fi

## libogg
if [ ! -f "${PREFIX}/lib/libogg.so" ]; then
    ${INSTALLER} -y install automake libtool

    rm -rf libogg
    git clone ${github_url}/gcp/libogg
    pushd libogg
    sh autogen.sh
    ./configure --prefix=${PREFIX}
    make
    make install
    popd
    rm -r libogg
fi

## vorbis

if [ ! -f "${PREFIX}/lib/libvorbis.so" ]; then
    libvorbis_folder=libvorbis-${vorbis_version}
    libvorbis_pkg=${libvorbis_folder}.tar.gz
    libvorbis_download_url=${github_url}/xiph/vorbis/releases/download/v${vorbis_version}/${libvorbis_pkg}

    rm -rf ${libvorbis_folder}
    curl -LO ${libvorbis_download_url}
    tar -xzvf ${libvorbis_pkg}

    pushd ${libvorbis_folder}
    ./configure --prefix=${PREFIX}
    make
    make install
    popd
    rm ${libvorbis_pkg}
    rm -r ${libvorbis_folder}
fi

## ffmpeg
rm -rf FFmpeg
git clone ${github_url}/FFmpeg/FFmpeg
pushd FFmpeg
git checkout tags/${ffmpeg_version}
${INSTALLER} -y install diffutils
./configure --prefix=${PREFIX} --disable-x86asm --enable-libmp3lame --enable-libvorbis --enable-libopus
make
make install
popd

rm -r FFmpeg
popd