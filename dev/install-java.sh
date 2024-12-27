#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

java_repo_home=${repo_home}/java

# jdk & jre
bash ./install-jdk.sh ${jdk_old_version}
bash ./install-jdk.sh ${jdk_new_version} JDK_HOME false

# maven
bash ./install-maven.sh

# gradle
bash ./install-gradle.sh

# ant
bash ./install-ant.sh

# other profile

echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin ${java_mark}" >> /etc/profile

popd