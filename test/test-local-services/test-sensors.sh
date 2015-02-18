#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
start_test
USNAME=UnitServer
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
if [ -n "$4" ];then
    USNAME="$4"
fi
if [ -n "$5" ];then
    ACQUIRE_S="$5"
fi

info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU,METADATASERVER:$META"


if launch_us_cu $NUS $NCU $META $USNAME;then
    if ! check_proc $USNAME;then
	error_mesg "$USNAME quitted"
	end_test 1 "$USNAME quitted"
    fi
fi

info_mesg "${#us_proc[@]} Unit(s) running correctly " "performing test..."
for ((us=0;us<$NUS;us++));do
    for ((cu=0;cu<$NCU;cu++));do
	if init_cu $META "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "- init TEST_UNIT_$us/TEST_CU_$cu"
	else
	    nok_mesg "- init TEST_UNIT_$us/TEST_CU_$cu"
	    end_test 1 "initializing TEST_UNIT_$us/TEST_CU_$cu"
	fi
	if start_cu $META "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "- start TEST_UNIT_$us/TEST_CU_$cu"
	else
	    nok_mesg "- start TEST_UNIT_$us/TEST_CU_$cu"
	    end_test 1 "starting TEST_UNIT_$us/TEST_CU_$cu"
	fi
    done
done



if get_timestamp_cu $META "TEST_UNIT_0/TEST_CU_0";then
    ok_mesg "- timestamp start"
    start_timestamp=$timestamp_cu
else
    nok_mesg "- timestamp start"
    end_test 1 "getting initial timestamp "
fi

rm /tmp/hexp_dataset_*-*-*-* >& /dev/null
cnt=0
while ((cnt<ACQUIRE_S));do
    for ((us=0;us<$NUS;us++));do
	for ((cu=0;cu<$NCU;cu++));do
	    if get_dataset_cu $META "TEST_UNIT_$us/TEST_CU_$cu";then
		ok_mesg "- $cnt/$ACQUIRE_S dataset TEST_UNIT_$us/TEST_CU_$cu"
		echo "$dataset_cu" >> /tmp/hexp_dataset_$us-$cu-$start_timestamp-0
		end_timestamp=$timestamp_cu
	    else
		nok_mesg "- $cnt/$ACQUIRE_S dataset TEST_UNIT_$us/TEST_CU_$cu"
		end_test 1 "getting dataset of TEST_UNIT_$us/TEST_CU_$cu"
	    fi
	done;
    done;
    ((cnt++))
    sleep 1
done;

for ((us=0;us<$NUS;us++));do
    for ((cu=0;cu<$NCU;cu++));do
	mv /tmp/hexp_dataset_$us-$cu-$start_timestamp-0 /tmp/hexp_dataset_$us-$cu-$start_timestamp-$end_timestamp
    done
done

stop_proc $USNAME
end_test 0
