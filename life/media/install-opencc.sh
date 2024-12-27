#!/bin/bash
set -exo pipefail

cd /tmp

## cmake >= 3.14
cmake_has_installed=`cmake --version || true`
if [ -n "${cmake_has_installed}" ]; then
    echo "cmake has installed"
    if [ -f /usr/local/bin/cmake ]; then
        export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
    fi
else
    echo "cmake has not installed!"
    exit 1
fi

python2_has_installed=`python2 -c "print()" || true`
if [ -n "${python2_has_installed}" ]; then
    echo "python2 has installed"
else
    echo "python2 is not installed"
    ${INSTALLER} -y install python2
fi

if [ ! -L /usr/bin/python ]; then
    ln -s /usr/bin/python2 /usr/bin/python
fi

## doxygen
${INSTALLER} -y install flex bison
rm -rf doxygen
git clone ${github_url}/doxygen/doxygen
cd doxygen
git checkout tags/${doxygen_version}

mkdir build
cd build
cmake -G "Unix Makefiles" .. && make && make install

## opencc
cd /tmp
rm -rf OpenCC
git clone ${github_url}/BYVoid/OpenCC
cd OpenCC
make && make install
if [ ! -L /usr/lib64/libopencc.so.1.1 ]; then
    ln -s /usr/lib/libopencc.so.1.1 /usr/lib64/libopencc.so.1.1
fi

cd ..
rm -r doxygen && rm -r OpenCC