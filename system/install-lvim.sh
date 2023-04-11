#!/bin/bash
set -exo pipefail

# cargo
bash ./dev/install-rust.sh

if [ -f ${HOME}/.local/share/lunarvim ]; then
    echo "zsh has installed"
    exit 0
fi

source /etc/profile
source ${HOME}/.profile

pushd /tmp

${INSTALLER} -y install curl wget zip unzip make cmake git
if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install gettext python3 python3-devel
fi

# install neovim (stable)
curl -LO ${github_url}/neovim/neovim/archive/refs/tags/stable.tar.gz
tar -xzvf stable.tar.gz && rm stable.tar.gz
pushd neovim-stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
make install
popd
rm -r neovim-stable

# install lvim (newest)
curl -LO ${github_url}/LunarVim/LunarVim/archive/refs/heads/master.zip
unzip master.zip && rm master.zip
pushd LunarVim-master
bash ./utils/installer/install.sh -y
popd
rm -r LunarVim-master

popd