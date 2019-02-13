#!/bin/env bash

# This script is used to launch JMeter master and slaves.

WORKING_DIR=`pwd`

SLAVES=1

PNAME="test"
mkdir $WORKING_DIR/${2:-$PNAME}
echo "project name is " ${2:-$PNAME}

echo
echo "Checking kubernetes is present or not"

if ! hash kubectl 2>/dev/null

then
    echo "'kubectl' was not found in PATH"
    echo "Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
  exit
 fi

echo

 kubectl version --short

echo

NS=ert-test

 echo "Checking ERT-TEST namespace availabilty"


 kubectl get namespace ${NS} | grep -v NAME | awk '{print $1}'

 echo

 echo ${NS}" is aviable "

 echo 

 echo "***************Starting jmeter deploymnet****************"

 echo

# slaves=`awk '{print $NF}' "$WORKING_DIR/slaves"`
echo "Creating your project environment configuratin files"

sed "s/jmeter-slave/jmeter-slave-${2:-$PNAME}/g ; s/jmeter_mode: slave/jmeter_mode: slave-${2:-$PNAME}/g" $WORKING_DIR/jslave_deploy.yaml > $WORKING_DIR/${2:-$PNAME}/jslave_deploy_${2:-$PNAME}.yaml
sed "s/jmeter-slave-svc/jmeter-slave-svc-${2:-$PNAME}/g ; s/jmeter_mode: slave/jmeter_mode: slave-${2:-$PNAME}/g" $WORKING_DIR/jslave_svc.yaml > $WORKING_DIR/${2:-$PNAME}/jslave_svc_${2:-$PNAME}.yaml
sed "s/jmeter-master/jmeter-master-${2:-$PNAME}/g ; s/configname/configname-${2:-$PNAME}/g" $WORKING_DIR/jmaster_deploy.yaml > $WORKING_DIR/${2:-$PNAME}/jmaster_deploy_${2:-$PNAME}.yaml
sed "s/configname/configname-${2:-$PNAME}/g ; s/jmeter-slave-svc/jmeter-slave-svc-${2:-$PNAME}/g" $WORKING_DIR/jmaster_config.yaml > $WORKING_DIR/${2:-$PNAME}/jmaster_config_${2:-$PNAME}.yaml
 echo

 echo "Total JMeter slaves for this test is " ${1:-$SLAVES}

echo "jmeter slave deploymnet starting......"

    echo

    kubectl create -n $NS -f $WORKING_DIR/${2:-$PNAME}/jslave_deploy_${2:-$PNAME}.yaml

    echo

    kubectl create -n $NS -f $WORKING_DIR/${2:-$PNAME}/jslave_svc_${2:-$PNAME}.yaml


    echo

 #   sleep 5


    kubectl -n $NS scale deployment/jmeter-slave-${2:-$PNAME} --replicas=${1:-$SLAVES}
echo
echo "jmeter slave deployment completed."

echo

echo "JMeter Master deploymnet starting......"

echo

kubectl create -n $NS -f $WORKING_DIR/${2:-$PNAME}/jmaster_config_${2:-$PNAME}.yaml

echo

kubectl create -n $NS -f $WORKING_DIR/${2:-$PNAME}/jmaster_deploy_${2:-$PNAME}.yaml


echo
echo "***************JMeter master deployment completed******************"

echo
kubectl get -n $NS all

echo namespace = $NS > $WORKING_DIR/ns_export

echo

echo "Environment is ready now and you can proceed with your test"


