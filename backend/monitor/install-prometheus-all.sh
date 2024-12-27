#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

sh prometheus/install-prometheus.sh

sh alertmanager/install-alertmanager.sh

sh node_exporter/install-nodeexporter.sh

sh pushgateway/install-pushgateway.sh

popd