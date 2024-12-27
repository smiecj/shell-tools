#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

minio_home=${modules_home}/minio

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/minio*
    sed -i "s#{minio_home}#${minio_home}#g" /usr/local/bin/minio*
}

if [ -f "${minio_home}/minio" ]; then
    echo "minio has installed, will only copy scripts"
    copy_scripts
    exit 0
else
    echo "minio has not installed!"
fi

pushd /tmp

rm -rf minio
git clone ${github_url}/minio/minio -b ${minio_branch}

pushd minio

make build

mkdir -p ${minio_home}
mv minio ${minio_home}

popd

rm -r minio

popd

copy_scripts

cp conf/minio.properties ${minio_home}

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${minio_home}/minio.properties
done

popd
