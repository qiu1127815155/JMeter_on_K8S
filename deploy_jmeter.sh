#!/bin/env bash
#This script is used for launching JMeter Master and Slaves on kubernetes cluster

working_dir=`pwd`

echo "Checking kubernetes is present or not"

if ! hash kubectl 2>/dev/null

  then
      echo"'kubectl' was not found in PATH"
   exit
 fi
 
 echo
 
 kubectl version --short
 
 echo
 
 NS=ert-test
 
 echo "Checking ERT-TEST namespace availablity"
 
 kubectl get namespace $NS |grep -v NAME |awk'{print $1}'
 
 echo
 echo $NS " is available"
 echo
 echo "**********Starting JMeter Deployment**********"
 echo
 echo "JMter Slave(s) deployment starting..."
 echo
 kubectl apply -n $NS -f $working_dir/jslave_deploy.yaml
 echo
 kubectl apply -n $NS -f $working_dir/jslave_svc.yaml
 echo
 echo "JMter Slave(s) deployment completed."
 echo
 echo "JMter Master deployment starting..."
 echo
 kubectl apply -n $NS -f $working_dir/jmaster_configmap.yaml
 echo
 kubectl apply -n $NS -f $working_dir/jmaster_deploy.yaml
 echo
 echo "**********JMeter Deployment Completed**********"
 echo
 kubectl get -n $NS all
      
