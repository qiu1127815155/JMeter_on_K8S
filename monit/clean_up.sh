#!/bin/env bash
working_dir=`pwd`

NS=performance-testing

# kubectl -n $NS delete service/grafana-svc
# kubectl -n $NS delete deployment/grafana
# kubectl -n $NS delete configmap/grafana-config

sleep 2

kubectl -n $NS delete service/influxdb-svc
kubectl -n $NS delete deployment/influxdb
kubectl -n $NS delete configmap/influxdb-config




echo "Environment has been released from cluster"
