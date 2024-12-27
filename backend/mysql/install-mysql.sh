#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

mysql_home=${modules_home}/mysql
mysql_init_sql_home=${mysql_home}/init_sql

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/mysql*
    sed -i "s#{mysql_home}#${mysql_home}#g" /usr/local/bin/mysql*
    sed -i "s#{mysql_init_sql_home}#${mysql_init_sql_home}#g" /usr/local/bin/mysql*

    # create soft link for other service use mysql client
    ln -s ${mysql_home}/bin/mysql /usr/local/bin/mysql || true
    ln -s ${mysql_home}/bin/mysqldump /usr/local/bin/mysqldump || true
}

# mysql_has_installed=`mysql --version || true`
# if [ -n "${mysql_has_installed}" ]; then
#     echo "mysql has installed in system"
#     exit 0
# else
#     echo "mysql has not installed!"
# fi

if [ -d "${mysql_home}" ]; then
    echo "mysql path ${mysql_home} not empty, will only copy scripts"
    copy_scripts
    exit 0
fi

# compile mysql -- local router1 / test_emr

mysql_folder=mysql-server-mysql-${mysql_version}
mysql_pkg=mysql-${mysql_version}.zip
mysql_download_url=${github_url}/mysql/mysql-server/archive/refs/tags/mysql-${mysql_version}.zip

pushd /tmp

if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install bison openssl-devel libtirpc-devel
else
    ${INSTALLER} -y install bison libssl-dev libtirpc-dev pkg-config
    # apt -y install g++
fi
# rpcgen: make rpcgen

# rm -rf ${mysql_folder}

if [ ! -d ${mysql_folder} ]; then
    curl -LO ${mysql_download_url}
    unzip ${mysql_pkg}
fi

pushd ${mysql_folder}

cmake_param="-DCMAKE_INSTALL_PREFIX=${mysql_home} -DMYSQL_DATADIR=${mysql_data_dir} -DWITH_DEBUG=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=boost -DBISON_EXECUTABLE=/usr/bin/bison -DFORCE_INSOURCE_BUILD=1 -DCOMPILE_WARNING_AS_ERROR=false"
export mysql_use_local_ld_library=false

# gcc requirement: https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/source-installation-prerequisites.html

if [ -f "/usr/local/bin/gcc" ]; then
    libc_found=`find /usr/local -name 'libc.so' | wc -l`
    libstdc_found=`find /usr/local -name 'libstdc++.so' | wc -l`
    if [ $libc_found -gt 0 ] || [ $libstdc_found -gt 0 ]; then
        export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
        export mysql_use_local_ld_library=true
    fi

    cmake_param="${cmake_param} -DCMAKE_C_COMPILER=/usr/local/bin/gcc -DCMAKE_CXX_COMPILER=/usr/local/bin/g++"
fi

# https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/${BOOST_TARBALL}
## boost download timeout
sed -i "s#DOWNLOAD_BOOST_TIMEOUT [0-9]\+#DOWNLOAD_BOOST_TIMEOUT 7200#g" cmake/boost.cmake

# 5.7: boost download url
# https://github.com/mysql/mysql-server/blob/mysql-5.7.44/cmake/boost.cmake#L44C11-L44C47
sed -i "s#http://sourceforge.net/projects/boost/files#${sourceforge_repo}/boost#g" cmake/boost.cmake

# skip abi check
if [ "true" == "${mysql_skip_abi_check}" ]; then
    sed -i "s#.*abi_check.cmake.*##g" CMakeLists.txt
fi

cmake . ${cmake_param}

make
make install

popd

rm -f ${mysql_pkg}
rm -rf ${mysql_folder}

popd

mkdir -p ${mysql_init_sql_home}

cp conf/* ${mysql_home}

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${mysql_home}/mysql.properties || true
done

copy_scripts

popd