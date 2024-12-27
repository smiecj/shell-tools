#!/bin/bash
set -exo pipefail

# https://www.cnblogs.com/ajanuw/p/16378265.html

pushd /tmp

# meson installed check
python_env_suffix=`echo ${python_version} | tr '.' '_'`
conda_env_name_python=py${python_env_suffix}
source ${CONDA_HOME}/bin/activate ${conda_env_name_python}

meson_has_installed=`meson -V 2>/dev/null || true`
if [ -n "${meson_has_installed}" ]; then
    echo "meson has installed!"
    exit 0
else
    pip3 install meson
fi

if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install expat-devel libunwind-devel glib2-devel
else
    ${INSTALLER} -y install libexpat1-dev
fi

libvips_folder=libvips-${vips_version}
libvips_pkg=v${vips_version}.tar.gz
libvips_download_url=${github_url}/libvips/libvips/archive/refs/tags/${libvips_pkg}

rm -rf ${libvips_folder}
curl -LO ${libvips_download_url}
tar -xzvf ${libvips_pkg}

pushd ${libvips_folder}
meson setup build --prefix /usr/local

pushd build
meson compile
meson install
popd

popd

rm ${libvips_pkg}
rm -r ${libvips_folder}

popd