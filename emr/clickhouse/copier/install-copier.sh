#!/bin/bash
set -eo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

## env prepare
clickhouse_copier_home=${modules_home}/clickhouse/copier

mkdir -p ${clickhouse_copier_home}
pushd ${clickhouse_copier_home}

## https://github.com/ClickHouse/copier/releases/tag/
if [ "x86_64" == "${ARCH}" ]; then
    ARCH="amd64"
fi

copier_pkg=clickhouse-copier.${ARCH}.zip
curl -LO ${github_url}/ClickHouse/copier/releases/download/${clickhouse_copier_version}/${copier_pkg}
unzip ${copier_pkg}
rm ${copier_pkg}

rm -f /usr/local/bin/clickhouse-copier
ln -s ${clickhouse_copier_home}/clickhouse-copier /usr/local/bin/clickhouse-copier

popd
popd