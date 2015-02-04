#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
USNAME=UnitServer
NUS=5
NCU=10
if [ -n "$1" ];then
    NUS=$1
fi
if [ -n "$2" ];then
    NCU=$2
fi

if [ ! -x $CHAOS_PREFIX/bin/UnitServer ]; then
    nok_mesg "Generic UnitServer not found"
    exit 1
fi
check_proc_then_kill "$USNAME"

for ((us=0;us<$NUS;us++));do
    rm $CHAOS_PREFIX/log/UnitServer_$us.log >& /dev/null
    if run_proc "$CHAOS_PREFIX/bin/$USNAME --log-on-file --log-file $CHAOS_PREFIX/log/UnitServer_$us.log --unit_server_alias TEST_UNIT_$us --unit_server_enable true > /dev/null 2>&1 &" "$USNAME"; then
	ok_mesg "Generic UnitServer \"TEST_UNIT_$us\" started"
    else
	nok_mesg "Generic UnitServer \"TEST_UNIT_$us\" started"
	exit 1
    fi

    for ((cu=0;cu<$NCU;cu++));do
	info_mesg "checking for CU TEST_UNIT_$us/TEST_CU_$cu registration"
	if execute_command_until_ok "grep -o \"TEST_UNIT_$us\/TEST_CU_$cu .\+ successfully registered\" $CHAOS_PREFIX/log/UnitServer_$us.log >& /dev/null" 30; then
	    ok_mesg "CU \"TEST_UNIT_$us/TEST_CU_$cu\" registered"
	else
	    nok_mesg "CU \"TEST_UNIT_$us/TEST_CU_$cu\" registered"
	    exit 1
	fi

	info_mesg "checking \"TEST_UNIT_$us/TEST_CU_$cu\" accessibility from UI"
	if loop_cu_test "localhost:5000" "TEST_UNIT_$us/TEST_CU_$cu" 3;then
	    ok_mesg "UI access to \"TEST_UNIT_$us/TEST_CU_$cu\""
	else
	    nok_mesg "UI access \"TEST_UNIT_$us/TEST_CU_$cu\""
	    exit 1
	fi

	if init_cu "localhost:5000" "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "Init \"TEST_UNIT_$us/TEST_CU_$cu\""
	else
	    nok_mesg "Init \"TEST_UNIT_$us/TEST_CU_$cu\""
	    exit 1
	fi

	if start_cu "localhost:5000" "TEST_UNIT_$us/TEST_CU_$cu";then
	    ok_mesg "Start \"TEST_UNIT_$us/TEST_CU_$cu\""
	else
	    nok_mesg "Start \"TEST_UNIT_$us/TEST_CU_$cu\""
	    exit 1
	fi

    done	
done    

stop_proc $USNAME

