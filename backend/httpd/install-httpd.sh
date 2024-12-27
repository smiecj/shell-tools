#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

httpd_home=${modules_home}/httpd

if [ -d "/usr/local/apache2" ]; then
    echo "httpd has installed"
    exit 0
fi

# https://www.cnblogs.com/tushanbu/p/16473452.html

pushd /tmp

if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install expat-devel
else
    ${INSTALLER} -y install libexpat1-dev
fi

# install apr
if [ ! -f "/usr/local/apr" ]; then
    apr_folder=apr-${apr_version}
    apr_pkg=${apr_folder}.tar.gz
    apr_pkg_url=${apache_repo}/apr/${apr_pkg}

    rm -f ${apr_pkg}
    rm -rf ${apr_folder}
    curl -LO ${apr_pkg_url}
    tar -xzvf ${apr_pkg}
    pushd ${apr_folder}
    ./configure
    make && make install
    popd
    rm ${apr_pkg}
    rm -r ${apr_folder}

    apr_util_folder=apr-util-${apr_util_version}
    apr_util_pkg=${apr_util_folder}.tar.gz
    apr_util_pkg_url=${apache_repo}/apr/${apr_util_pkg}

    rm -rf ${apr_util_folder}
    rm -f ${apr_util_pkg}
    curl -LO ${apr_util_pkg_url}
    tar -xzvf ${apr_util_pkg}
    pushd ${apr_util_folder}
    ./configure --with-apr=/usr/local/apr/
    make && make install
    popd
    rm ${apr_util_pkg}
    rm -r ${apr_util_folder}
fi

# install httpd
httpd_folder=httpd-${httpd_version}
httpd_pkg=${httpd_folder}.tar.gz
httpd_pkg_url=${apache_repo}/httpd/${httpd_pkg}

rm -f ${httpd_pkg}
rm -rf ${httpd_folder}
curl -LO ${httpd_pkg_url}
tar -xzvf ${httpd_pkg}
pushd ${httpd_folder}
./configure
make && make install
popd
rm ${httpd_pkg}
rm -r ${httpd_folder}

popd

# scripts and configs

mkdir -p ${httpd_home}
cp conf/* ${httpd_home}
cp scripts/* /usr/local/bin
chmod +x /usr/local/bin/httpd*

sed -i "s#{httpd_home}#${httpd_home}#g" /usr/local/bin/httpd*

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${httpd_home}/httpd.properties
done

popd
