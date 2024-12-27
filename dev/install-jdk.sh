#!/bin/bash
set -eo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

jdk_short_version=8
jdk_env_key="JAVA_HOME"
cover_path=true
if [ -n "$1" ]; then
    jdk_short_version=$1
fi
if [ -n "$2" ]; then
    jdk_env_key=$2
fi
if [ -n "$3" ]; then
    cover_path=true
fi

jdk_repo=${github_url}/adoptium/temurin${jdk_short_version}-binaries

java_repo_home=${repo_home}/java

if [ "x86_64" == "${ARCH}" ]; then
    ARCH="x64"
fi

# install java
mkdir -p ${java_home}
mkdir -p ${java_repo_home}

pushd ${java_home}

echo "use \`git ls-remote ${jdk_repo}\` to get jdk actual version of ${jdk_short_version}"

jdk_version=`git ls-remote --tags --sort='v:refname' ${jdk_repo} 2>/dev/null | grep -E "(jdk-${jdk_short_version}|jdk${jdk_short_version})" | grep -v beta | grep -vE "\.[0-9]+$" | tail -n 1 | sed 's#.* ##g' | sed 's#.*tags/##g'`

echo "use \`git ls-remote ${jdk_repo}\` get jdk actual version: ${jdk_version}"

jdk_download_version=`echo ${jdk_version} | sed 's#jdk##g' | sed 's#-##g' | sed 's#+#_#g'`

jdk_pkg=OpenJDK${jdk_short_version}U-jdk_${ARCH}_linux_hotspot_${jdk_download_version}.tar.gz
jdk_folder=${jdk_version}
jdk_download_url=${jdk_repo}/releases/download/${jdk_version}/${jdk_pkg}

jre_pkg=OpenJDK${jdk_short_version}U-jre_${ARCH}_linux_hotspot_${jdk_download_version}.tar.gz
jre_folder=${jdk_version}-jre
jre_download_url=${jdk_repo}/releases/download/${jdk_version}/${jre_pkg}

echo "jdk download url: ${jdk_download_url}, jre download url: ${jre_download_url}"

curl -LO ${jdk_download_url}
curl -LO ${jre_download_url}

tar -xzvf ${jdk_pkg}
tar -xzvf ${jre_pkg}

rm ${jdk_pkg}
rm ${jre_pkg}

popd

# profile
java_mark="# java"
echo -e "\n${java_mark}" >> /etc/profile
echo "export ${jdk_env_key}=${java_home}/${jdk_folder} ${java_mark}" >> /etc/profile
if [ ${jdk_env_key} == "JAVA_HOME" ]; then
    echo "export JRE_HOME=${java_home}/${jre_folder} ${java_mark}" >> /etc/profile
fi
if [ ${jdk_short_version} == "8" ]; then
    echo "export CLASSPATH=.:\$${jdk_env_key}/lib/dt.jar:\$${jdk_env_key}/lib/tools.jar:\$JRE_HOME/lib ${java_mark}" >> /etc/profile
fi
if [ "true" == "${cover_path}" ]; then
    echo "export PATH=\$PATH:\$${jdk_env_key}/bin ${java_mark}" >> /etc/profile
fi

popd