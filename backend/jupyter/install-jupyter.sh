#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

jupyterhub_home=${modules_home}/jupyterhub
jupyterhub_config_home=${jupyterhub_home}/config
export jupyterhub_user_config_home=${jupyterhub_config_home}/user

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/jupyter*

    sed -i "s#{jupyterhub_home}#${jupyterhub_home}#g" /usr/local/bin/jupyter*
    sed -i "s#{jupyter_env_name}#${jupyter_env_name}#g" /usr/local/bin/jupyter*
    sed -i "s#{jupyterhub_config_home}#${jupyterhub_config_home}#g" /usr/local/bin/jupyter*
}

# check conda

conda_has_installed=`conda -V 2>/dev/null || true`
if [ -n "${conda_has_installed}" ]; then
    echo "conda has installed"
else
    echo "conda has not installed!"
    exit 1
fi

# check npm
npm_has_installed=`npm -v || true`
if [ -n "${npm_has_installed}" ]; then
    echo "npm has installed"
else
    echo "npm has not installed!"
    exit 1
fi

# check if jupyter env exists, if not, create it
jupyter_env_has_installed=`conda list installed -n ${jupyter_env_name} || true`
if [ -n "${jupyter_env_has_installed}" ]; then
    echo "jupyter env ${jupyter_env_name} has installed"
else
    echo "jupyter env ${jupyter_env_name} is not installed, will install it"
    conda create -y --name ${jupyter_env_name} python=${jupyterhub_python_version}
fi

if [ -d "${jupyterhub_home}" ]; then
    echo "jupyter has installed, will only copy scripts"
    copy_scripts
    exit 0
else
    echo "jupyter has not installed!"
fi

source ${CONDA_HOME}/bin/activate ${jupyter_env_name}

# install jupyter

mkdir -p ${jupyterhub_home}
mkdir -p ${jupyterhub_config_home}
cp ./conf/jupyterhub_config_template.py ${jupyterhub_config_home}

pushd ${jupyterhub_home}

## install npm component
npm install -g configurable-http-proxy@${configurable_http_proxy_version}

## install jupyter (lab)
pip3 install jupyterhub-idle-culler
pip3 install jupyterlab==${jupyterlab_version}
pip3 install jupyterhub==${jupyterhub_version}

## pymysql for db
pip3 install pymysql

## plugins & extensions
pip3 install jupyterlab-code-formatter==${jupyterlab_code_formatter_version}
pip3 install autopep8 black
pip3 install jupyter-resource-usage==${jupyter_resource_usage_version}
pip3 install jupyterlab_execute_time==${jupyterlab_execute_time_version}

pip3 install 'python-lsp-server[all]'
pip3 install jupyterlab-lsp==${jupyterlab_lsp_version}

popd

## copy scripts and config
cp -r conf/* ${jupyterhub_config_home}

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${jupyterhub_config_home}/jupyterhub.properties
done

popd