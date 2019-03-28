#!/bin/env bash

WORKING_DIR=`pwd`

NS="${NS:-performance-testing}"        # namespace "Default value ERT-TEST"

file=$WORKING_DIR/dashboard.json
echo

echo "starting MonIT deploymnet"

echo

echo "Influx DB Deployment starting..."

kubectl create -n $NS -f  $WORKING_DIR/influx_config.yaml

kubectl create -n $NS -f  $WORKING_DIR/influx_deploy.yaml

kubectl create -n $NS -f  $WORKING_DIR/influx_svc.yaml

INFLUX_POD=`kubectl get po -n $NS | grep influxdb | awk '{print $1}'`

kubectl exec -ti -n $NS $INFLUX_POD -- influx -execute 'CREATE DATABASE jmeter'
echo
echo "Influx DB Deployment completed and JMETER DB created"

echo

#sleep 5

echo "Grafana Deployment starting..."
echo
 kubectl create -n $NS -f  $WORKING_DIR/grafana_config.yaml

 kubectl create -n $NS -f  $WORKING_DIR/grafana_deploy.yaml

 kubectl create -n $NS -f  $WORKING_DIR/grafana_svc.yaml

GRAFANA_POD=`kubectl get po -n $NS | grep grafana | awk '{print $1}'`

GRAFANA_PODIP=`kubectl get svc -n $NS | grep grafana | awk '{print $3}'`

echo

#echo $GRAFANA_PODIP
 
 
 sleep 3
# {"username":"admin","password":"Pa55word","org":"ert","bucket":"jmeter"}
kubectl exec -ti -n $NS $GRAFANA_POD -- curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://influxdb-svc:8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'

kubectl -n $NS get po | grep influxdb
echo
echo
kubectl -n $NS get svc | grep influxdb

echo
echo "Grafana deployment completed"
