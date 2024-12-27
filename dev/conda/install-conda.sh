#!/bin/bash
set -ex pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

miniconda_install_path="${modules_home}/miniconda"
conda_env_key_home="CONDA_HOME"

miniforge_url="${github_url}/conda-forge/miniforge/releases/download"

add_profile() {
    conda_mark="# conda"
    # check_conda_mark_exists=`cat /etc/profile | grep "${conda_mark}" || true`
    # if [ -z "${check_conda_mark_exists}" ]; then
    # fi
    sed -i "s/.*${conda_mark}.*//g" /etc/profile
    echo -e "\n# conda" >> /etc/profile
    echo "export $conda_env_key_home=$miniconda_install_path ${conda_mark}" >> /etc/profile
    echo "export PATH=\$PATH:\$$conda_env_key_home/bin ${conda_mark}" >> /etc/profile
    source /etc/profile
}

# copy_scripts() {
#     cp scripts/* /usr/local/bin
#     chmod +x /usr/local/bin/conda*
# }

# installed check
conda_has_installed=`conda -V 2>/dev/null || true`
if [ -n "${conda_has_installed}" ] || [ -d "${miniconda_install_path}" ]; then
    echo "conda has installed, will only copy scripts and add profile"
    add_profile
    # copy_scripts
    exit 0
fi

if [ -d "${miniconda_install_path}" ]; then
    echo "conda path ${miniconda_install_path} not empty, will only add profile and copy scripts"
    exit 0
fi

# install basic
${INSTALLER} -y install curl

## download conda
# critical libmamba filesystem error: cannot copy symlink: Invalid argument [/opt/modules/miniconda/pkgs/ncurses-6.5-hcccb83c_1/share/terminfo/E/Eterm-color] [/opt/modules/miniconda/share/terminfo/E/Eterm-color]
conda_install_script=miniforge_install.sh
conda_forge_download_url=${miniforge_url}/${conda_forge_version}/Miniforge3-${conda_forge_version}-Linux-${ARCH}.sh
echo "miniforge download url: $conda_forge_download_url"
curl -L $conda_forge_download_url -o ${conda_install_script}
bash ${conda_install_script} -b -p ${miniconda_install_path}
rm ${conda_install_script}

## conda repo
cp ./${condarc_file} ${HOME}/.condarc

add_profile

## add scripts

# copy_scripts

popd