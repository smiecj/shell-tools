#!/bin/bash
set -exo pipefail

mkdir -p ${module_home}

pushd ${module_home}

firefox_pkg=firefox-${firefox_version}.tar.bz2
firefox_pkg_url=${firefox_mirror}/pub/firefox/releases/${firefox_version}/linux-x86_64/${firefox_language}/${firefox_pkg}
${INSTALLER} -y install bzip2

curl -LO ${firefox_pkg_url}
tar -jxvf ${firefox_pkg}
rm ${firefox_pkg}

popd