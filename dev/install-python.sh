#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

miniconda_install_path="${modules_home}/miniconda"
conda_env_key_home="CONDA_HOME"
python_env_key_home="PYTHON_HOME"
python_lib_key_home="PYTHON_LIB_HOME"

python_env_suffix=`echo ${python_version} | tr '.' '_'`
python_main_version=`echo ${python_version} | sed 's#\..*##g'`

conda_env_name_python=py${python_env_suffix}

miniforge_url="${github_url}/conda-forge/miniforge/releases/download"

# installed check
conda_has_installed=`conda -V 2>/dev/null || true`
if [ -n "${conda_has_installed}" ]; then
    echo "conda has installed!"
else
    sh ./conda/install-conda.sh
fi

## create default python env
${miniconda_install_path}/bin/conda create -y --name ${conda_env_name_python} python=${python_version}
${miniconda_install_path}/bin/conda config --set auto_activate_base false

## profile
python_home_path=${miniconda_install_path}/envs/${conda_env_name_python}
python_lib_path=${miniconda_install_path}/envs/${conda_env_name_python}/lib/python${python_version}/site-packages

# conda profile: no need anymore
# conda_mark="# conda"
# sed -i "s/.*${conda_mark}.*//g" /etc/profile
# echo -e "\n# conda & python" >> /etc/profile
# echo "export $conda_env_key_home=$miniconda_install_path ${conda_mark}" >> /etc/profile
# echo "export $python_env_key_home=$python_home_path ${conda_mark}" >> /etc/profile
# echo "export $python_lib_key_home=$python_lib_path ${conda_mark}" >> /etc/profile
# echo "export PATH=\$PATH:\$$python_env_key_home/bin:\$$conda_env_key_home/bin ${conda_mark}" >> /etc/profile

## python soft link
python_bin=python${python_main_version}
pip_bin=pip${python_main_version}
if [ ! -f /usr/bin/${python_bin} ]; then
    ln -s ${python_home_path}/bin/${python_bin} /usr/bin/${python_bin}
    rm -f /usr/bin/${pip_bin} && ln -s $python_home_path/bin/${pip_bin} /usr/bin/${pip_bin}
fi

## pip repo
mkdir -p ~/.pip && cp ./python/pip.conf ~/.pip
sed -i "s#{pip_repo}#${pip_repo}#g" ~/.pip/pip.conf
sed -i "s#{pip_trusted_host}#${pip_trusted_host}#g" ~/.pip/pip.conf

popd