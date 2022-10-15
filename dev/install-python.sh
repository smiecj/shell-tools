#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

miniconda_install_path="${modules_home}/miniconda"
conda_env_key_home="CONDA_HOME"
python3_env_key_home="PYTHON3_HOME"
python3_lib_key_home="PYTHON3_LIB_HOME"

conda_env_name_python3=py3
python3_version=3.8

miniforge_url="${github_url}/conda-forge/miniforge/releases/download"

# installed check
conda_has_installed=`conda -V || true`
if [ -n "${conda_has_installed}" ]; then
    echo "conda has installed!"
    exit 0
fi

## download conda
arch=`uname -p` && \
conda_install_script=miniforge_install.sh && \
conda_forge_download_url=${miniforge_url}/${conda_forge_version}/Miniforge3-${conda_forge_version}-Linux-${arch}.sh && \
echo "miniforge download url: $conda_forge_download_url" && \
curl -L $conda_forge_download_url -o ${conda_install_script} && \
bash $conda_install_script -b -p ${miniconda_install_path} && rm -f ${conda_install_script}

## conda repo
cp ./conda/condarc ${HOME}/.condarc

## create default python env
${miniconda_install_path}/bin/conda create -y --name ${conda_env_name_python3} python=${python3_version}
${miniconda_install_path}/bin/conda config --set auto_activate_base false

## profile
python3_home_path=${miniconda_install_path}/envs/${conda_env_name_python3}
python3_lib_path=${miniconda_install_path}/envs/${conda_env_name_python3}/lib/python${python3_version}/site-packages
### clean mark
conda_mark="# conda"
sed -i "s/.*${conda_mark}.*//g" /etc/profile
echo -e "\n# conda & python" >> /etc/profile
echo "export $conda_env_key_home=$miniconda_install_path ${conda_mark}" >> /etc/profile
echo "export $python3_env_key_home=$python3_home_path ${conda_mark}" >> /etc/profile
echo "export $python3_lib_key_home=$python3_lib_path ${conda_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$$python3_env_key_home/bin:\$$conda_env_key_home/bin ${conda_mark}" >> /etc/profile

## python soft link
rm -f /usr/bin/python3 && ln -s ${python3_home_path}/bin/python3 /usr/bin/python3
rm -f /usr/bin/pip3 && ln -s $python3_home_path/bin/pip3 /usr/bin/pip3

## pip repo
cd ~ && mkdir -p .pip && cd .pip && rm -f pip.conf && \
    echo '[global]' >> pip.conf && \
    echo "index-url = ${pip_repo}" >> pip.conf
