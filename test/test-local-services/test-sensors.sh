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

declare -A dataset
for ((us=0;us<$NUS;us++));do
    for ((cu=0;cu<$NCU;cu++));do

	cnt=0
	start_timestamp=0
	end_timestamp=0
	info_mesg "acquiring dataset of TEST_UNIT_$us/TEST_CU_$cu for " "$ACQUIRE_S s"
	if get_timestamp_cu $META "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "- timestamp TEST_UNIT_$us/TEST_CU_$cu"
	    start_timestamp=$timestamp_cu
	else
	    nok_mesg "- timestamp TEST_UNIT_$us/TEST_CU_$cu"
	    end_test 1 "getting initial timestamp of TEST_UNIT_$us/TEST_CU_$cu"
	fi
	rm /tmp/dataset >/dev/null
	while ((cnt<ACQUIRE_S));do
	    
	    if get_dataset_cu $META "TEST_UNIT_$us/TEST_CU_$cu";then
		ok_mesg "- $cnt/$ACQUIRE_S dataset TEST_UNIT_$us/TEST_CU_$cu"
       
	    else
		nok_mesg "- $cnt/$ACQUIRE_S dataset TEST_UNIT_$us/TEST_CU_$cu"
		end_test 1 "getting dataset of TEST_UNIT_$us/TEST_CU_$cu"
	    fi
	    ## acquire and store dataset
	    dataset["$timestamp_cu"]="$dataset_cu"
	    echo "$dataset_cu" >> /tmp/dataset
	    ((cnt++))
	    sleep 1
	done
	if get_timestamp_cu $META "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "- timestamp TEST_UNIT_$us/TEST_CU_$cu"
	    end_timestamp=$timestamp_cu
	else
	    nok_mesg "- timestamp TEST_UNIT_$us/TEST_CU_$cu"
	    end_test 1 "getting final timestamp of TEST_UNIT_$us/TEST_CU_$cu"
	fi

	info_mesg "acquisition for TEST_UNIT_$us/TEST_CU_$cu ended interval " "$end_timestamp-$start_timestamp"
	rm /tmp/hexp_dataset_$us-$cu >/dev/null
	for i in ${!dataset[@]};do
	    echo "${dataset[$i]}" >> /tmp/hexp_dataset_$us-$cu
	done

	if get_hdataset_cu $META "TEST_UNIT_$us/TEST_CU_$cu" $start_timestamp $end_timestamp /tmp/hdataset_$end_timestamp-$start_timestamp;then
	    ok_mesg "historical data retrived" 
	else
	    nok_mesg "historical data retrived" 
	    end_test 1 "retriving historical data of TEST_UNIT_$us/TEST_CU_$cu"
	fi
    done;
done;
stop_proc $USNAME
end_test 0
