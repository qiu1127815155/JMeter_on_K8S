
#!/bin/env bash


WORKING_DIR=`pwd`

NS=$(awk '{print $NF}' "$WORKING_DIR"/ns_export)

PDIR=$1

TESTDATA_DIR=$2

PNAME=$3

D="$(date +'%d-%m-%Y_%H:%M:%S')"

if [ ! -d "$PDIR" ];
then
    echo "JMETER Project directory was not found"
    echo "Kindly check and input the correct file path"
    exit
fi

#DATAFILES_COUNT=$(find $TESTDATA_DIR -type f -name | wc -l)

UNIQUE_FLAG=$(find $TESTDATA_DIR -mindepth 1 -type d | wc -l )




master_pod=$(kubectl get po -n "$NS" | grep jmeter-master-$PNAME | awk '{print $1}')
slave_pods=($(kubectl get po -n "$NS" | grep jmeter-slave-$PNAME | awk '{print $1}'))

kubectl cp "${PDIR}/$PNAME.jmx" -n "$NS" "$master_pod":/$PNAME.jmx

slavesnum=${#slave_pods[@]}
slavedigits="${#slavesnum}"

j=1
if [ $UNIQUE_FLAG -gt 0 ]

    then
     
         for ((i=0; i<=$(($slavesnum-1)); i++));
            do
                  
               kubectl -n "$NS" exec ${slave_pods[i]} -- bash -c "rm -rf /$PNAME"
               kubectl -n "$NS" cp "$TESTDATA_DIR"/$[j] "${slave_pods[i]}":/$PNAME
               let j=j+1
            done 

               kubectl -n "$NS" exec -ti  "$master_pod" -- /bin/bash  /load_test "/$PNAME.jmx" "/jresults/$3_$D.jtl"

    else
        for ((i=0; i<=$(($slavesnum-1)); i++));
            do
                kubectl -n "$NS" exec ${slave_pods[i]} -- bash -c "rm -rf /$PNAME"
                kubectl -n "$NS" cp "$TESTDATA_DIR" "${slave_pods[i]}":/$PNAME
                
            done 


            kubectl -n "$NS" exec -ti  "$master_pod" -- /bin/bash  /load_test "/$PNAME.jmx" "/jresults/$3_$D.jtl"
fi
