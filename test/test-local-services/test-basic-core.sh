#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
start_test
USNAME=UnitServer
NUS=5
NCU=10
META="localhost:5000"
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

info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU,METADATASERVER:$META"

if [ -n "$5" ];then
    info_mesg "Creating noise process..."
    if run_proc "$PWD/create-noise-requests.sh $NUS $NCU $META > $CHAOS_PREFIX/log/create-noise-requests.out 2>&1 &" "create-noise-requests.sh"; then
	PIDNOISE=$proc_pid
	ok_mesg "noise process created successfully pid $PIDNOISE"
    else
	nok_mesg "cannot create noise request process"
	end_test 1 "cannot create noise request process"
    fi
fi

if launch_us_cu $NUS $NCU $META $USNAME;then
    if ! check_proc $USNAME;then
	error_mesg "$USNAME quitted"
	killall -9 create-noise-requests.sh
	end_test 1 "$USNAME quitted"
    fi
fi

info_mesg "${#us_proc[@]} Unit(s) running correctly " "performing test..."
for ((us=0;us<$NUS;us++));do
    for ((cu=0;cu<$NCU;cu++));do
	
	info_mesg "checking \"TEST_UNIT_$us/TEST_CU_$cu\" accessibility from UI"
	if loop_cu_test "$META" "TEST_UNIT_$us/TEST_CU_$cu" 4 ${us_proc[$us]};then
	    ok_mesg "UI access to \"TEST_UNIT_$us/TEST_CU_$cu\""
    else
	    nok_mesg "UI access \"TEST_UNIT_$us/TEST_CU_$cu\""
	    killall -9 create-noise-requests.sh >& /dev/null
	    end_test 1 "UI access \"TEST_UNIT_$us/TEST_CU_$cu\""
	fi
	
	if init_cu "$META" "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "Init \"TEST_UNIT_$us/TEST_CU_$cu\""
	else
	nok_mesg "Init \"TEST_UNIT_$us/TEST_CU_$cu\""
	killall -9 create-noise-requests.sh >& /dev/null
	end_test 1 "Init \"TEST_UNIT_$us/TEST_CU_$cu\""
	fi
	
	if start_cu "$META" "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "Start \"TEST_UNIT_$us/TEST_CU_$cu\""
	else
	    nok_mesg "Start \"TEST_UNIT_$us/TEST_CU_$cu\""
	    killall -9 create-noise-requests.sh >& /dev/null
	    end_test 1 "Start \"TEST_UNIT_$us/TEST_CU_$cu\""
	fi
	if ! check_proc $USNAME;then
	    error_mesg "$USNAME quitted"
	    killall -9 create-noise-requests.sh >& /dev/null
	    end_test 1 "$USNAME quitted"
	fi

    done
done    
stop_proc $USNAME
killall -9 create-noise-requests.sh >& /dev/null
end_test 0
