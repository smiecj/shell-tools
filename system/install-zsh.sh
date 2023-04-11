#!/bin/bash
set -exo pipefail

source /etc/profile

if [ -f ${HOME}/.oh-my-zsh ]; then
    echo "zsh has installed"
    exit 0
fi

rm -rf ${HOME}/.oh-my-zsh

${INSTALLER} -y install git

## install zsh (compile new version for theme powerlevel10k)
pushd /tmp
rm -rf zsh
git clone ${zsh_repo} -b ${zsh_branch}
pushd zsh
${INSTALLER} -y install autoconf gcc 
${INSTALLER} -y install ncurses-devel || true
${INSTALLER} -y install ncurses-dev || true
./Util/preconfig
# with-tcsetpgrp: fix configure: error: no controlling tty
## https://github.com/habitat-sh/core-plans/issues/2632
./configure --prefix=/usr --with-tcsetpgrp
make && make install.bin && make install.modules && make install.fns
popd
rm -r zsh

## install ohmyzsh
git clone ${zsh_ohmyzsh_repo} && mv ohmyzsh ~/.oh-my-zsh
mv -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
popd

${INSTALLER} -y install util-linux-user || true
chsh -s /bin/zsh

## plugin: autosuggestions
git clone ${zsh_autosuggestion_repo} ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

## plugin: syntax highlighting
git clone ${zsh_syntax_highlighting_repo} ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

## don't auto update
### https://stackoverflow.com/questions/11378607/oh-my-zsh-disable-would-you-like-to-check-for-updates-prompt
sed -i '1s/^/DISABLE_AUTO_UPDATE=true\nDISABLE_UPDATE_PROMPT=true\n/' ~/.zshrc

## theme config: powerlevel10k
sed -i 's#^ZSH_THEME=.*#ZSH_THEME="powerlevel10k/powerlevel10k"#g' ~/.zshrc

git clone --depth=1 ${zsh_powerlevel10k_repo} ~/.oh-my-zsh/custom/themes/powerlevel10k
${INSTALLER} -y install wget
~/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install

cp ~/.oh-my-zsh/custom/themes/powerlevel10k/example/p10k.zh ~/.p10k.zsh

echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> ~/.zshrc

### match *
echo "setopt nonomatch" >> ~/.zshrc

### not share history between session
echo "unsetopt share_history" >> ~/.zshrc

### don't notice when remove multiple files
#### https://stackoverflow.com/a/27995504
echo "setopt RM_STAR_SILENT" >> ~/.zshrc

### source profile
echo "source /etc/profile" >> ~/.zshrc

### set zsh ignore git status to avoid too slow
#### https://stackoverflow.com/a/25864063
git config --global --add oh-my-zsh.hide-status 1
git config --global --add oh-my-zsh.hide-dirty 1