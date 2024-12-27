#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

## env prepare
clickhouse_home=${modules_home}/clickhouse
server_property_file="server.properties"
user_property_file="user.properties"

main_config_template_file="config_template.xml"
main_config_file="config.xml"
users_config_template_file="users_config_template.xml"
users_config_file="users_config.xml"

clickhouse_config_path="/etc/clickhouse-server"
clickhouse_pid_path="/var/run/clickhouse-server"

clickhouse_main_config_path=/etc/clickhouse-server/config.xml
clickhouse_user_config_path=/etc/clickhouse-server/users.xml

copy_scripts() {
    cp scripts/* /usr/local/bin
    chmod +x /usr/local/bin/clickhouse*
    sed -i "s#{clickhouse_home}#${clickhouse_home}#g" /usr/local/bin/clickhouse*
    sed -i "s#{clickhouse_main_config_path}#${clickhouse_main_config_path}#g" /usr/local/bin/clickhouse*
    sed -i "s#{clickhouse_user_config_path}#${clickhouse_user_config_path}#g" /usr/local/bin/clickhouse*
}

if [ -f "/usr/bin/clickhouse-server" ] && [ -d "/var/lib/clickhouse" ]; then
    echo "clickhouse has installed, will only copy scripts"
    copy_scripts
    exit 0
else
    echo "clickhouse has not installed"
fi

# install clickhouse
mkdir -p ${clickhouse_home}
pushd ${clickhouse_home}

${INSTALLER} -y install expect bc

## https://packages.clickhouse.com/rpm/stable/
clickhouse_rpm_common_name="clickhouse-common-static-${clickhouse_version}.${ARCH}.rpm"
clickhouse_rpm_client_name="clickhouse-client-${clickhouse_version}.${ARCH}.rpm"
clickhouse_rpm_server_name="clickhouse-server-${clickhouse_version}.${ARCH}.rpm"

curl -LO ${clickhouse_repo}/rpm/stable/${clickhouse_rpm_common_name}
curl -LO ${clickhouse_repo}/rpm/stable/${clickhouse_rpm_client_name}
curl -LO ${clickhouse_repo}/rpm/stable/${clickhouse_rpm_server_name}

# remove old rpms
rpm -qa | grep clickhouse-common-static | xargs -I {} bash -c "rpm -e {} --nodeps" || true
rpm -qa | grep clickhouse-client | xargs -I {} bash -c "rpm -e {} --nodeps" || true
rpm -qa | grep clickhouse-server | xargs -I {} bash -c "rpm -e {} --nodeps" || true

expect_password_str="Enter password for default user"
rpm -ivh ${clickhouse_rpm_common_name}
rpm -ivh ${clickhouse_rpm_client_name}
expect -c "spawn rpm -ivh ${clickhouse_rpm_server_name};expect \"${expect_password_str}\";send \"${clickhouse_server_default_password}\n\";interact"

rm ${clickhouse_rpm_common_name} ${clickhouse_rpm_client_name} ${clickhouse_rpm_server_name}

# recreate user for start without systemd
id -u clickhouse &>/dev/null && userdel clickhouse && rm -rf /home/clickhouse && rm -f /var/spool/mail/clickhouse
id -u clickhouse-bridge &>/dev/null && userdel clickhouse-bridge && rm -rf /home/clickhouse-bridge && rm -f /var/spool/mail/clickhouse-bridge
id -u clickhouse &>/dev/null || useradd clickhouse || true
id -u clickhouse-bridge &>/dev/null || useradd clickhouse-bridge || true

mkdir -p ${clickhouse_data_path} && chown -R clickhouse:clickhouse ${clickhouse_data_path}
mkdir -p ${clickhouse_tmp_path} && chown -R clickhouse:clickhouse ${clickhouse_tmp_path}
mkdir -p ${clickhouse_pid_path} && chown -R clickhouse:clickhouse ${clickhouse_pid_path}
mkdir -p /var/log/clickhouse-server && chown -R clickhouse:clickhouse /var/log/clickhouse-server
mkdir -p /var/lib/clickhouse && chown -R clickhouse:clickhouse /var/lib/clickhouse
chown -R clickhouse:clickhouse ${clickhouse_config_path}

# for podman
rm /etc/security/limits.d/clickhouse.conf

popd

cp conf/* ${clickhouse_home}

env_keys=`printenv | sed "s#=.*##g"`
for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" ${clickhouse_home}/*.properties
done

copy_scripts

popd

## 迁移:  core1 - core3 -> router2 - core4 - core5