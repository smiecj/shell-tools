#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

miniconda_install_path="${modules_home}/miniconda"
conda_env_key_home="CONDA_HOME"

miniforge_url="${github_url}/conda-forge/miniforge/releases/download"

# installed check
conda_has_installed=`conda -V || true`
if [ -n "${conda_has_installed}" ]; then
    echo "conda has installed!"
    exit 0
fi

# install basic
${INSTALLER} -y install curl

## download conda
arch=`uname -p` && \
conda_install_script=miniforge_install.sh && \
conda_forge_download_url=${miniforge_url}/${conda_forge_version}/Miniforge3-${conda_forge_version}-Linux-${arch}.sh && \
echo "miniforge download url: $conda_forge_download_url" && \
curl -L $conda_forge_download_url -o ${conda_install_script} && \
rm -rf ${miniconda_install_path} && \
bash $conda_install_script -b -p ${miniconda_install_path} && rm -f ${conda_install_script}

## conda repo
cp ./conda/${condarc_file} ${HOME}/.condarc

### clean mark
conda_mark="# conda"
sed -i "s/.*${conda_mark}.*//g" /etc/profile
echo -e "\n# conda" >> /etc/profile
echo "export $conda_env_key_home=$miniconda_install_path ${conda_mark}" >> /etc/profile
echo "export PATH=\$PATH:\$$conda_env_key_home/bin ${conda_mark}" >> /etc/profile
