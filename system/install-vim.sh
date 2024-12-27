#!/bin/bash
set -exo pipefail

### https://www.vim.org/git.php

# cargo
bash ./dev/install-rust.sh

if [ -f ${HOME}/.local/share/lunarvim ]; then
    echo "zsh has installed"
    exit 0
fi


source /etc/profile
source ${HOME}/.profile

pushd /tmp

git clone https://github.com/vim/vim.git

## 当前: 支持安装 vim 最新

### 当前: router1 编译失败

yum -y remove vim vim-runtime gvim vim-tiny vim-common vim-gui-common

git checkout tags/v8.2.5172

find /usr -name '*config-*' | grep python3 | grep "linux-gnu" | head -n 1


./configure --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp=yes \
    --enable-python3interp=yes \
    --with-python-config-dir=/usr/lib/python3.8/config-3.8-x86_64-linux-gnu \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --enable-gui=gtk2 \
    --enable-cscope \
    --prefix=/usr/local

make && make install

git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go

## 当前: 配置 vim-go
## https://www.xy1413.com/p/vim_go/
# let g:go_info_mode='gopls'
# let g:go_def_mode='gopls'

popd