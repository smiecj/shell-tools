#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

superset_home=${modules_home}/superset

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/superset*
    sed -i "s#{superset_home}#${superset_home}#g" /usr/local/bin/superset*
}

# check conda

conda_has_installed=`conda -V 2>/dev/null || true`
if [ -n "${conda_has_installed}" ]; then
    echo "conda has installed"
else
    echo "conda has not installed!"
    exit 1
fi

# check if env exists, if not, create it
superset_env_has_installed=`conda list installed -n ${superset_env_name} || true`
if [ -n "${superset_env_has_installed}" ]; then
    echo "superset env ${superset_env_name} has installed"
else
    echo "superset env ${superset_env_name} is not installed, will install it"
    conda create -y --name ${superset_env_name} python=${superset_python_version}
fi

if [ -d "${superset_home}" ]; then
    echo "superset has installed, will only copy scripts"
    copy_scripts
    exit 0
else
    echo "jupyter has not installed!"
fi


source ${CONDA_HOME}/bin/activate ${superset_env_name}

pip3 uninstall -y apache-superset==${superset_tag}
pip3 install apache-superset==${superset_tag}
pip3 install pymysql

mkdir -p ${superset_home}
cp conf/* ${superset_home}

## replace github url in examples

site_package_path=`python3 -c 'import site; print(site.getsitepackages())' | sed -E "s#('|\[|\])##g"`

sed -i "s#\"https://github.com#\"${github_url}#g" ${site_package_path}/superset/examples/helpers.py
sed -i "s# https://raw.githubusercontent.com# ${github_raw}#g" ${site_package_path}/superset/examples/configs/datasets/examples/*
sed -i "s# https://github.com# ${github_url}#g" ${site_package_path}/superset/examples/configs/datasets/examples/*

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${superset_home}/superset.properties
done

copy_scripts

popd