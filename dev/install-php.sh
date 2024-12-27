#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

# https://blog.cpming.top/p/package-requirements-sqlite3-were-not-met

${INSTALLER} -y update
if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install sqlite-devel
else
    ${INSTALLER} -y install pkg-config libxml2-dev libsqlite3-dev
fi

pushd /tmp

php_folder=php-${php_version}
php_pkg=${php_folder}.tar.gz
curl -LO https://www.php.net/distributions/${php_pkg}
rm -rf ${pkg_folder}
tar -xzvf ${php_pkg}

pushd ${php_folder}

./configure -prefix=${PREFIX}
make && make install

popd

rm -r ${php_folder}

popd