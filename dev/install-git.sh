#!/bin/bash
set -exo pipefail

# check git exists, if exist, notice user to remove it
system_git_has_installed=`ls -l /usr/bin/git || true`
if [ -n "${system_git_has_installed}" ]; then
    echo "system git has installed, you can remove it first by '${INSTALLER} -y remove git'"
    exit 0
fi

# check git if still exists
git_has_installed=`git version || true`
if [ -n "${git_has_installed}" ]; then
    echo "git has installed"
    exit 0
fi

git_home=${modules_home}/git

## libcurl-devel for git-remote-https
## gettext for msgfmt
## https://unix.stackexchange.com/a/694512
## https://github.com/desktop/desktop/issues/10345#issuecomment-757507413
## https://stackoverflow.com/a/65876436
## https://github.com/sabotage-linux/gettext-tiny/issues/16#issuecomment-1625404810
if [ "yum" == "${INSTALLER}" ]; then
    ${INSTALLER} -y install zlib-devel libcurl-devel autoconf gettext gcc curl
else
    ${INSTALLER} -y install zlib1g-dev libcurl4-openssl-dev autoconf gettext tcl-dev gcc curl
fi

# install git

pushd /tmp

rm -rf git*
git_source_pkg=v${git_version}.tar.gz
git_source_folder=git-${git_version}
curl -LO ${github_url}/git/git/archive/refs/tags/${git_source_pkg}
tar -xzvf ${git_source_pkg}
pushd ${git_source_folder}

autoconf
./configure --prefix=${git_home}
make -j4
make install -j4

popd

rm -r git*

popd

# git_mark="# git"
# sed -i "s/.*${git_mark}.*//g" /etc/profile
# echo -e "\n${git_mark}" >> /etc/profile
# echo "export GIT_HOME=${git_home} ${git_mark}" >> /etc/profile
# echo "export PATH=\$PATH:\$GIT_HOME/bin ${git_mark}" >> /etc/profile

rm -f /usr/local/bin/git
ln -s ${git_home}/bin/git /usr/local/bin/git