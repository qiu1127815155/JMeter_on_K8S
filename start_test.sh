#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir="`pwd`"

#Get namesapce variable
NS=`awk '{print $NF}' "$working_dir/ns_export"`

jmx="$1"
PANME="$2"
[ -n "$jmx" ] || read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$jmx")"
#Get Master pod details

master_pod=`kubectl get po -n $NS | grep jmeter-master-$2 | awk '{print $1}'`

kubectl cp "$jmx" -n $NS "$master_pod:/$test_name"

## Echo Starting Jmeter load test

echo "kubectl exec -ti -n $NS $master_pod -- /bin/bash /load_test /"$test_name""
kubectl exec -ti -n $NS $master_pod -- /bin/bash /load_test /"$test_name"
