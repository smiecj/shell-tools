#!/bin/bash

export $(xargs < {hue_home}/desktop/conf/hue.properties)

db_engine={hue_db_engine}
db_host={hue_db_host}
db_port={hue_db_port}
db_user={hue_db_user}
db_password={hue_db_password}

mysql_connect_command="mysql -h${db_host} -P${db_port} -u${db_user} -p${db_password}"

# wait mysql start finish
while :
do
    mysql_connect_ret_exec=`${mysql_connect_command} -e "select version()"`
    mysql_connect_ret=$?
    if [[ 0 == ${mysql_connect_ret} ]]; then
        echo "mysql has start"
        break
    else
        echo "mysql has not start, will wait for it"
        sleep 3
    fi
done

# check whether table has created
table_check=`${mysql_connect_command} -D${db_db} -e "show create table desktop_document2"`
table_check_ret=$?
if [[ 0 != ${table_check_ret} ]]; then
    {hue_home}/build/env/bin/hue syncdb --noinput
    {hue_home}/build/env/bin/hue migrate
    ${mysql_connect_command} -e "alter database ${db_db} character set utf8"
    ${mysql_connect_command} -D${db_db} -e "ALTER TABLE desktop_document2 CHARACTER SET utf8, COLLATE utf8_general_ci"
    ${mysql_connect_command} -D${db_db} -e "alter table beeswax_queryhistory modify `query` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL"
    ${mysql_connect_command} -D${db_db} -e "ALTER TABLE desktop_document2 modify column name varchar(255) CHARACTER SET utf8"
    ${mysql_connect_command} -D${db_db} -e "ALTER TABLE desktop_document2 modify column description longtext CHARACTER SET utf8"
    ${mysql_connect_command} -D${db_db} -e "ALTER TABLE desktop_document2 modify column search longtext CHARACTER SET utf8"
fi