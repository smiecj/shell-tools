#!/bin/bash
set -ex pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

doris_home=${modules_home}/doris

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/doris*
    sed -i "s#{doris_home}#${doris_home}#g" /usr/local/bin/doris*
}

if [ -d "${doris_home}" ] && [ -d "${doris_home}/fe/lib" ] ; then
    echo "doris has installed, will only copy scripts"
    copy_scripts
    exit 0
fi

pushd /tmp

doris_folder=apache-doris-${doris_version}-bin-${ARCH_SHORT}
doris_pkg=${doris_folder}.tar.gz
doris_download_url=https://apache-doris-releases.oss-accelerate.aliyuncs.com/${doris_pkg}

# doris_folder=`ls -l ./ | grep -E "^d" | grep "doris" | sed 's/.* //g'`
rm -rf ${doris_folder}
curl -LO ${doris_download_url}
tar -xzvf ${doris_pkg}

mkdir -p ${doris_home}
mv ./${doris_folder}/* ${doris_home}
rm -r ${doris_folder}
rm ${doris_pkg}

popd

# doris java home: primarly use new jdk 11 or 17
if [ -z "${doris_java_home}" ]; then
    jdk_new_path=`ls ${java_home} | grep "jdk-${jdk_new_version}" | grep -v "jre" || true`
    if [ -n "${jdk_new_path}" ]; then
        export doris_java_home=${java_home}/${jdk_new_path}
    else
        echo "warn: cannot find system jdk, you can manually set doris_java_home in doris.properties"
    fi
fi

mkdir ${doris_home}/conf
cp conf/* ${doris_home}/conf

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${doris_home}/conf/doris.properties
done

copy_scripts

popd
