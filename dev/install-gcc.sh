#!/bin/bash
set -exo pipefail

# dependency
${INSTALLER} -y install diffutils bzip2
if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install gcc-c++
else
    ${INSTALLER} -y install g++
fi

pushd /tmp

gcc_pkg=gcc-${gcc_version}.tar.gz
gcc_folder=gcc-${gcc_version}

rm -rf ${gcc_folder}

curl -LO ${gnu_repo}/gcc/gcc-${gcc_version}/${gcc_pkg}
tar -xvf gcc-${gcc_version}.tar.gz
pushd ${gcc_folder}
sed -i "s#base_url=.*#base_url='${gcc_pub_repo}/infrastructure/'#g" ./contrib/download_prerequisites
# gcc_pub_ftp_repo=`echo ${gcc_pub_repo} | sed -i 's#https://#ftp://#g'`
sed -i "s#wget ftp://gcc.gnu.org/pub/gcc#curl -LO ${gcc_pub_repo}#g" ./contrib/download_prerequisites
sed -i "s#fetch='wget'#fetch='curl -LO'#g" ./contrib/download_prerequisites
./contrib/download_prerequisites
mkdir -p build
pushd build && ../configure -prefix=${PREFIX} --enable-checking=release --enable-languages=c,c++ --disable-multilib && make && make install && popd
popd

rm -rf ${gcc_folder} && rm -f ${gcc_pkg}

# gcc_mark="# gcc"
# sed -i "s/.*${gcc_mark}.*//g" /etc/profile
# echo -e "\n${gcc_mark}" >> /etc/profile
# echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH ${gcc_mark}" >> /etc/profile

# export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

popd
