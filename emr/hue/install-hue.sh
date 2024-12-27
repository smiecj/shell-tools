#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

# check nodejs install
nodejs_has_installed=`npm -v || true`
if [ -z "${nodejs_has_installed}" ]; then
    echo "nodejs is not installed!"
    exit 1
fi

# apt -y install mysql-client / yum -y install mysql
# make jq

hue_home=${modules_home}/hue

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/hue*
    sed -i "s#{hue_home}#${hue_home}#g" /usr/local/bin/hue*
}

if [ -d "${hue_home}" ]; then
    echo "hue has installed, will only copy scripts"
    copy_scripts
    exit 0
fi

conda_home=${modules_home}/miniconda

conda_has_installed=`${conda_home}/bin/conda -V 2>/dev/null || true`
if [ -n "${conda_has_installed}" ]; then
    echo "conda has installed"
else
    echo "conda has not installed!"
    exit 1
fi

# check env exists, if not, create it
hue_env_has_installed=`${conda_home}/bin/conda list installed -n ${hue_env_name} || true`
if [ -n "${hue_env_has_installed}" ]; then
    echo "hue env ${hue_env_name} has installed"
else
    echo "hue env ${hue_env_name} is not installed, will install it"
    conda create -y --name ${hue_env_name} python=${hue_python_version}
fi

source ${conda_home}/bin/activate ${hue_env_name}

pushd /tmp

if [ ! -d hue ]; then
    git clone ${github_url}/smiecj/hue -b ${hue_branch}
fi

# basic env
if [ "apt" == "${INSTALLER}" ]; then
    # python2 python2-dev
    ${INSTALLER} -y install python3-dev libsasl2-dev libmysqlclient-dev libsqlite3-dev libldap-dev g++ pkg-config
elif [ "yum" == "${INSTALLER}" ]; then
    # python38-devel
    # cmake
    ${INSTALLER} -y install make gcc gcc-c++ cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-plain libffi-devel libxml2 libxml2-devel libxslt libxslt-devel mysql-devel openldap-devel sqlite-devel gmp-devel
fi

pushd hue

# https://stackoverflow.com/a/69746937
node_version=`node -v`
if [[ "${node_version}" > "v18" ]]; then
    export NODE_OPTIONS=--openssl-legacy-provider
fi

sed -i "s#git+https://github.com#git+${github_url}#g" desktop/core/requirements.txt

## install hue
hue_module_parent=$(dirname ${hue_home})
# python_version=#{hue_python_version}
# python_env_name=${py_hue}
python_main_version=`echo ${hue_python_version} | sed 's#\..*##g'`
python_bin=python${hue_python_version}
pip_bin=pip${python_main_version}

export PYTHON_VER=python${hue_python_version}
export PYTHON_H=${conda_home}/envs/${hue_env_name}/include/python${hue_python_version}/Python.h
export SYS_PYTHON=${conda_home}/envs/${hue_env_name}/bin/${python_bin}
export SYS_PIP=${CONDA_HOME}/envs/${hue_env_name}/bin/${pip_bin}

rm -rf ${hue_module_parent}/hue
mkdir -p ${hue_module_parent}

rm -rf build
PREFIX=${hue_module_parent} make SYS_PIP=${SYS_PIP} install

popd

# rm -r hue

popd

# cp -r /opt/modules/hue_smiecj/hue/desktop/core/src/desktop/static/desktop/js /opt/modules/hue_smiecj/hue/build/static/desktop/

# move to hue dependencies
# /opt/modules/hue/build/env/bin/pip uninstall mysqlclient
# /opt/modules/hue/build/env/bin/pip install mysqlclient==2.1.1
# /opt/modules/hue/build/env/bin/pip uninstall django-prometheus
# /opt/modules/hue/build/env/bin/pip install django-prometheus==2.3.1

# config path

# scripts and configs

copy_scripts

cp conf/* ${hue_home}/desktop/conf

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${hue_home}/desktop/conf/hue.properties || true
done

popd