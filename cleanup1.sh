#!/bin/env bash
working_dir=`pwd`
PNAME="test"
NS=`awk '{print $NF}' "$working_dir/ns_export"`

kubectl -n $NS delete services/jmeter-slave-svc-${1:-$PNAME}

sleep 2

kubectl -n $NS delete deployments/jmeter-slave-${1:-$PNAME}

kubectl -n $NS delete deployments/jmeter-master-${1:-$PNAME}

sleep 2

kubectl -n $NS delete configmap/configname-${1:-$PNAME}

rm -rf $working_dir/${1:-$PNAME}
echo "Environment has been released from cluster"
