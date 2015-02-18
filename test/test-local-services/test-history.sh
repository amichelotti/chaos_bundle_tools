#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
start_test
NUS=5
NCU=10
META="localhost:5000"
ACQUIRE_S="120"
if [ -n "$1" ];then
    NUS=$1
fi
if [ -n "$2" ];then
    NCU=$2
fi
if [ -n "$3" ];then
    META="$3"
fi


info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU,METADATASERVER:$META"

lista=`ls /tmp/hexp_dataset_*-*-*-*`

for l in $lista;do
    if [[ "$l" =~ .+_([0-9]+)-([0-9]+)-([0-9]+)-([0-9]+) ]];then
	CUNAME="TEST_UNIT_${BASH_REMATCH[1]}/TEST_CU_${BASH_REMATCH[2]}"
	end=${BASH_REMATCH[3]}
	start=${BASH_REMATCH[4]}
	outh="/tmp/hdataset_${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]}-${BASH_REMATCH[4]}"
	info_mesg "retriving history for $CUNAME interval " "$end-$start"
	if get_hdataset_cu $META $CUNAME $start $end $outh;then
	    ok_mesg "history file $outh"
	else
	    nok_mesg "history file $outh"
	    end_test 1 "producing history for $CUNAME $end-$start"
	fi
    fi
done

end_test 0
