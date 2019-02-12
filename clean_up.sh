#!/bin/env bash
working_dir=`pwd`

NS=`awk '{print $NF}' "$working_dir/ns_export"`

kubectl delete --all services -n $NS

sleep 2

kubectl delete --all deployments -n $NS

sleep 2

kubectl delete --all configmap -n $NS


echo "Environment has been released from cluster"
