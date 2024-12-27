#!/bin/bash
set -eo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

clickhouse_copier_home=${modules_home}/clickhouse/copier
space_4="    "

# check copier
if [ ! -d ${clickhouse_copier_home} ]; then
    echo "copier home not exists"
    exit 0
fi
if [ ! -f ${clickhouse_copier_home}/clickhouse-copier ]; then
    echo "copier not exists"
    exit 0
fi

# check zookeeper client
zookeeper_home=${modules_home}/zookeeper
if [ ! -f ${zookeeper_home}/bin/zkCli.sh ]; then
    echo "zookeeper not exists"
    exit 0
fi

clickhouse_copier_conf_home=${clickhouse_copier_home}/conf
mkdir -p ${clickhouse_copier_conf_home}

# gen_zookeeper_config
gen_zookeeper_config() {
    zookeeper_nodes=$1

    zookeeper_conf_file=${clickhouse_copier_conf_home}/zookeeper.xml
    cp ./conf/zookeeper_template.xml ${zookeeper_conf_file}

    zk_address_arr=($(echo ${zookeeper_nodes} | tr "," "\n" | sort | uniq))
    zookeeper_replace_str=""
    for zk_address in ${zk_address_arr[@]}
    do
        IFS=':' read -r -a zk_split_list <<< $zk_address
        zk_host=${zk_split_list[0]}
        zk_port=${zk_split_list[1]}
        zookeeper_replace_str="${zookeeper_replace_str}\n$space_4$space_4<node>"
        zookeeper_replace_str="${zookeeper_replace_str}\n$space_4$space_4$space_4<host>$zk_host</host>"
        zookeeper_replace_str="${zookeeper_replace_str}\n$space_4$space_4$space_4<port>$zk_port</port>"
        zookeeper_replace_str="${zookeeper_replace_str}\n$space_4$space_4</node>"
    done
    zookeeper_replace_str="$zookeeper_replace_str\n$space_4"

    sed -i "s#{zookeeper_replace_str}#${zookeeper_replace_str}#g" ${zookeeper_conf_file}
}

## gen copier config
gen_copier_config() {
    local source_host=$1
    local source_port=$2
    local source_user=$3
    local source_password=$4
    
    local target_host=$5
    local target_port=$6
    local target_user=$7
    local target_password=$8

    local source_cluster_name=$9
    local target_cluster_name=${10}
    
    local db=${11}
    local table=${12}

    copier_conf_file=${clickhouse_copier_conf_home}/${db}_${table}.xml
    cp ./conf/copier_template.xml ${copier_conf_file}

    ## replace cluster config
    source_cluster_replace_str="$space_4$space_4<${source_cluster_name}>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4<shard>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4<internal_replication>true</internal_replication>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4<replica>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<default_database>${db}</default_database>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<host>${source_host}</host>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<port>${source_port}</port>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<user>${source_user}</user>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<password>${source_password}</password>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4$space_4</replica>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4$space_4</shard>"
    source_cluster_replace_str="${source_cluster_replace_str}\n$space_4$space_4</${source_cluster_name}>"

    target_cluster_replace_str="$space_4$space_4<${target_cluster_name}>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4<shard>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4<internal_replication>true</internal_replication>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4<replica>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<default_database>${db}</default_database>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<host>${target_host}</host>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<port>${target_port}</port>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<user>${target_user}</user>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4$space_4<password>${target_password}</password>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4$space_4</replica>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4$space_4</shard>"
    target_cluster_replace_str="${target_cluster_replace_str}\n$space_4$space_4</${target_cluster_name}>"

    sed -i "s#{source_cluster}#${source_cluster_replace_str}#g" ${copier_conf_file}
    sed -i "s#{target_cluster}#${target_cluster_replace_str}#g" ${copier_conf_file}
    
    ## create table stmt and create table sql
    create_table_stmt=`clickhouse-client --host ${source_host} --port ${source_port} --user "${source_user}" --password "${source_password}" --query="show create table ${db}.${table}"`
    create_table_engine_stmt=`echo ${create_table_stmt} | sed 's#.*ENGINE =#ENGINE =#g'`
    create_table_stmt_without_comment=`echo ${create_table_engine_stmt} | sed 's#COMMENT .*##g'`
    sed -i "s#{create_table_stmt}#${create_table_stmt_without_comment}#g" ${copier_conf_file}

    create_table_file=${clickhouse_copier_conf_home}/${db}_${table}.sql
    echo "${create_table_stmt}" > ${create_table_file}
    ### fix export sql cannot execute
    sed -i "s#\\\'#'#g" ${create_table_file}
    sed -i "s#\\\n#\n#g" ${create_table_file}
    sed -i "s#'${source_cluster_name}'#'${target_cluster_name}'#g" ${create_table_file}

    ## enabled partitions
    ### todo: clickhouse_copier_scan_not_exists_partition
    clickhouse_copier_enabled_partitions_replace_str=""
    if [ -n "${clickhouse_copier_enabled_partitions}" ]; then
        clickhouse_copier_enabled_partitions_replace_str="<enabled_partitions>"

        IFS=',' read -r -a enabled_partition_arr <<< "${clickhouse_copier_enabled_partitions}"
        for part in ${enabled_partition_arr[@]}
        do
            clickhouse_copier_enabled_partitions_replace_str="${clickhouse_copier_enabled_partitions_replace_str}\n$space_4$space_4$space_4$space_4<partition>'${part}'</partition>"
        done
        clickhouse_copier_enabled_partitions_replace_str="${clickhouse_copier_enabled_partitions_replace_str}\n$space_4$space_4$space_4</enabled_partitions>"
    fi
    sed -i "s#{clickhouse_copier_enabled_partitions}#${clickhouse_copier_enabled_partitions_replace_str}#g" ${copier_conf_file}

    ## other copier config
    sed -i "s#{clickhouse_copier_source_cluster_name}#${source_cluster_name}#g" ${copier_conf_file}
    sed -i "s#{clickhouse_copier_source_database}#${db}#g" ${copier_conf_file}
    sed -i "s#{clickhouse_copier_source_table}#${table}#g" ${copier_conf_file}
    sed -i "s#{clickhouse_copier_target_cluster_name}#${target_cluster_name}#g" ${copier_conf_file}
    sed -i "s#{clickhouse_copier_target_database}#${db}#g" ${copier_conf_file}
    sed -i "s#{clickhouse_copier_target_table}#${table}#g" ${copier_conf_file}

    sed -i "s#{clickhouse_copier_num_splits}#${clickhouse_copier_num_splits}#g" ${copier_conf_file}

    ## notice: some cluster table may not need migrate
}

## execute create table
execute_create_table() {
    local db=$1
    local table=$2

    local target_host=$3
    local target_port=$4
    local target_user=$5
    local target_password=$6

    create_table_file=${clickhouse_copier_conf_home}/${db}_${table}.sql
    
    if [ "1" == "${clickhouse_copier_recreate_table}" ]; then
        clickhouse-client --host ${target_host} --port ${target_port} --user "${target_user}" --password "${target_password}" --query "drop table ${db}.${table}" || true
    fi

    clickhouse-client --host ${target_host} --port ${target_port} --user "${target_user}" --password "${target_password}" --multiquery < ${create_table_file} || true
}

## execute migrage
execute_migrate() {
    if [ "1" != "${clickhouse_copier_migrate_enabled}" ]; then
        echo "clickhouse migrate is not enabled"
        return
    fi

    local zookeeper_nodes=$1
    local db=$2
    local table=$3
    local zk_data_path=$4
    local local_data_path=$5

    local target_host=$6
    local target_port=$7
    local target_user=$8
    local target_password=$9

    echo "[execute_migrate] to copy ${db}.${table}"

    ## check gen config exists
    copier_conf_file=${clickhouse_copier_conf_home}/${db}_${table}.xml
    if [ ! -f ${copier_conf_file} ]; then
        echo "[WARN] copier conf file not exists: ${copier_conf_file}"
        return
    fi

    ## check exists table
    if [ "0" == "${clickhouse_copier_copy_exists_table}" ]; then
        show_create_table_ret=`clickhouse-client --host ${target_host} --port ${target_port} --user "${target_user}" --password "${target_password}" --query="show create table ${db}.${table}" | grep "CREATE TABLE" || true`
        if [ -z "${show_create_table_ret}" ]; then
            echo "[execute_migrate] table ${db}.${tables} exists and will not copy"
            return
        fi
    fi

    ## create table
    execute_create_table ${db} ${table} ${target_host} ${target_port} ${target_user} ${target_password}

    ## ignore distributed table (only create)
    create_table_file=${clickhouse_copier_conf_home}/${db}_${table}.sql
    create_table_stmt=`cat ${create_table_file}`
    if [[ "${create_table_stmt}" =~ .*"ENGINE = Distributed".* ]]; then
        echo "[execute_migrate] table ${db}.${tables} is distributed table, will not copy data"
        return
    fi

    ## target cluster create db
    clickhouse-client --host ${target_host} --port ${target_port} --user "${target_user}" --password "${target_password}" --query="create database ${db}" || true

    ## check zk path depth: at least /dep01/dep02
    zk_data_path_depth=`echo ${zk_data_path} | tr '/' '\n' | wc -l`
    if [ ! ${zk_data_path_depth} -ge 2 ]; then
        echo "[execute_migrate] zk data path ${zk_data_path} depth is not larger than 1"
        return
    fi

    IFS=',' read -r -a zookeeper_node_arr <<< "${zookeeper_nodes}"
    zk_first_node=${zookeeper_node_arr[0]}
    zk_connect_cmd="${zookeeper_home}/bin/zkCli.sh -server ${zk_first_node}"

    ## clear path first
    ${zk_connect_cmd} deleteall ${zk_data_path} || true

    ## recursive create zk path
    IFS='/' read -r -a zk_data_path_split_arr <<< "${zk_data_path}"
    to_create_zk_path=""
    for current_zk_path in ${zk_data_path_split_arr[@]}
    do
        to_create_zk_path="${to_create_zk_path}/${current_zk_path}"
        ${zk_connect_cmd} create ${to_create_zk_path} || true
    done

    ## create task description
    ${zk_connect_cmd} create ${zk_data_path}/description
    ${zk_connect_cmd} set ${zk_data_path}/description "`cat ${copier_conf_file}`"

    zookeeper_conf_file=${clickhouse_copier_conf_home}/zookeeper.xml
    mkdir -p ${local_data_path}
    ${clickhouse_copier_home}/clickhouse-copier --config ${zookeeper_conf_file} --task-path ${zk_data_path} --base-dir ${local_data_path}
}

## clickhouse_copier_is_execute

get_all_dbs_from_server() {
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    dbs=`clickhouse-client --host ${host} --port ${port} --user "${user}" --password "${password}" --query="show databases" | sed -z 's#\n#;#g'`
    echo "${dbs}"
}

get_all_tables_from_server() {
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    local db=$5
    tables=`clickhouse-client --host ${host} --port ${port} --user "${user}" --password "${password}" --database ${db} --query="show tables" | sed -z 's#\n#;#g'`
    echo "${tables}"
}

main() {

# gen zk config
gen_zookeeper_config ${clickhouse_copier_zookeeper_nodes}

# gen and exec all table 
IFS=',' read -r -a source_server_host_arr <<< "${clickhouse_copier_source_server_nodes}"
IFS=',' read -r -a target_server_host_arr <<< "${clickhouse_copier_target_server_nodes}"

if [ "${#source_server_host_arr[@]}" != "${#target_server_host_arr[@]}" ]; then
    echo "[main] source server count not equals to target server count"
    exit 0
fi

for index in ${!source_server_host_arr[@]}
do
    current_source_server_host=${source_server_host_arr[${index}]}
    current_target_server_host=${target_server_host_arr[${index}]}
    if [ -z "${current_source_server_host}" ]; then
        continue
    fi
    dbs=`get_all_dbs_from_server ${current_source_server_host} ${clickhouse_server_tcp_port} ${clickhouse_server_default_user} ${clickhouse_server_default_password}`

    ## get all tables
    IFS=';' read -r -a db_arr <<< "${dbs}"
    for current_db in ${db_arr[@]}
    do
        # ignore system db
        if [ "system" == "${current_db}" ] || [ "INFORMATION_SCHEMA" == "${current_db}" ] || [ "information_schema" == "${current_db}" ] || [ "" == "${current_db}" ]; then
            continue
        fi
        # allow db
        if [ -n "${clickhouse_copier_allow_database}" ] && [ "${current_db}" != "${clickhouse_copier_allow_database}" ]; then
            echo "db ${current_db} not allow to copy"
            continue
        fi

        source_tables=`get_all_tables_from_server ${current_source_server_host} ${clickhouse_server_tcp_port} ${clickhouse_server_default_user} ${clickhouse_server_default_password} ${current_db}`
        target_tables=`get_all_tables_from_server ${current_target_server_host} ${clickhouse_server_tcp_port} ${clickhouse_server_default_user} ${clickhouse_server_default_password} ${current_db}`

        ## target table to map
        declare -A target_table_map
        IFS=';' read -r -a target_table_arr <<< "${target_tables}"
        for current_table in ${target_table_arr[@]}
        do
            target_table_map[${current_table}]=${current_table}
        done

        ## find need migrate source table
        IFS=';' read -r -a source_table_arr <<< "${source_tables}"
        for current_table in ${source_table_arr[@]}
        do
            if [ "" == "${current_table}" ]; then
                continue
            fi
            # allow table
            if [ -n "${clickhouse_copier_allow_tables}" ] && [[ "${current_table}" =~ "${clickhouse_copier_allow_tables}" ]]; then
                echo "table ${current_db}.${current_table} not allow to copy"
                continue
            fi

            # gen_migrate_config
            gen_copier_config ${current_source_server_host} ${clickhouse_server_tcp_port} ${clickhouse_server_default_user} ${clickhouse_server_default_password} \
                ${current_target_server_host} ${clickhouse_server_tcp_port} ${clickhouse_server_default_user} ${clickhouse_server_default_password} \
                ${clickhouse_copier_source_cluster_name} ${clickhouse_copier_target_cluster_name} \
                ${current_db} ${current_table}

            # execute migrate
            execute_migrate ${clickhouse_copier_zookeeper_nodes} ${current_db} ${current_table} ${clickhouse_copier_task_path} ${clickhouse_copier_base_dir} ${current_target_server_host} ${clickhouse_server_tcp_port} ${clickhouse_server_default_user} ${clickhouse_server_default_password}
        done
    done
done
}

main

popd