#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

flink_cdc_home=${modules_home}/flink-cdc

if [ -d "${flink_cdc_home}" ]; then
    echo "flink cdc has installed"
    exit 0
fi

# install flink cdc
mkdir -p ${flink_cdc_home}
pushd ${flink_cdc_home}

flink_cdc_folder=flink-cdc-${flink_cdc_version}
flink_cdc_pkg=${flink_cdc_folder}-bin.tar.gz
flink_cdc_pkg_url=${apache_repo}/flink/flink-cdc-${flink_cdc_version}/${flink_cdc_pkg}

if [ 'true' == "${COMPILE}" ]; then
    flink_cdc_source_folder=flink-cdc-${flink_cdc_version}
    flink_cdc_source_pkg=${flink_cdc_source_folder}-src.tgz
    flink_cdc_source_pkg_download_url=${apache_repo}/flink/flink-cdc-${flink_cdc_version}/${flink_cdc_source_pkg}
    rm -rf ${flink_cdc_source_folder}
    curl -LO ${flink_cdc_source_pkg_download_url}
    tar -xzvf ${flink_cdc_source_pkg}

    pushd ${flink_cdc_source_folder}
    mvn clean package -DskipTests -Dspotless.apply.skip -Dcheckstyle.skip -Dspotless.check.skip=true
    mv ./flink-cdc-dist/target/${flink_cdc_pkg} ../
    
    flink_cdc_snapshot_version=`cat pom.xml | grep revision | grep -v version | sed 's#.*<revision>##g' | sed 's#<.*##g'`
    IFS=',' read -r -a flink_cdc_pipeline_connector_arr <<< ${flink_cdc_pipeline_connectors}
    for current_pipeline_connector in ${flink_cdc_pipeline_connector_arr[@]}
    do
        IFS=':' read -r -a current_pipeline_connector_arr <<< ${current_pipeline_connector}
        current_pipeline_connector_name=${current_pipeline_connector_arr[0]}

        current_pipeline_connector_jar=flink-cdc-pipeline-connector-${current_pipeline_connector_name}-${flink_cdc_snapshot_version}.jar
        mv ./flink-cdc-connect/flink-cdc-pipeline-connectors/flink-cdc-pipeline-connector-${current_pipeline_connector_name}/target/${current_pipeline_connector_jar} ../
    done
    popd

    rm -r ${flink_cdc_source_folder}
    rm ${flink_cdc_source_pkg}
else
    curl -LO ${flink_cdc_pkg_url}

    IFS=',' read -r -a flink_cdc_pipeline_connector_arr <<< ${flink_cdc_pipeline_connectors}
    for current_pipeline_connector in ${flink_cdc_pipeline_connector_arr[@]}
    do
        IFS=':' read -r -a current_pipeline_connector_arr <<< ${current_pipeline_connector}
        current_pipeline_connector_name=${current_pipeline_connector_arr[0]}
        current_pipeline_connector_version=${current_pipeline_connector_arr[1]}

        current_pipeline_connector_jar=flink-cdc-pipeline-connector-${current_pipeline_connector_name}-${current_pipeline_connector_version}.jar
        current_pipeline_connector_jar_url=${maven_repo}/com/ververica/flink-cdc-pipeline-connector-${current_pipeline_connector_name}/${current_pipeline_connector_version}/${current_pipeline_connector_jar}
        
        curl -LO ${current_pipeline_connector_jar_url}
    done
fi

tar -xvf ${flink_cdc_pkg}
rm ${flink_cdc_pkg}
mv ./${flink_cdc_folder}/* ./
rm -r ${flink_cdc_folder}

# mysql connector
mysql_connector_jar=mysql-connector-java-${flink_cdc_mysql_connector_version}.jar
mysql_connector_jar_url=${maven_repo}/mysql/mysql-connector-java/${flink_cdc_mysql_connector_version}/${mysql_connector_jar}
curl -LO ${mysql_connector_jar_url}
mv ./${mysql_connector_jar} lib/

# flink pipeline connector
mv flink*pipeline-connector*jar lib/

popd

# todo: scripts and configs

popd
