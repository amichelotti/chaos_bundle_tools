#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
USNAME=UnitServer
if [ ! -x $CHAOS_PREFIX/bin/UnitServer ]; then
    nok_mesg "Generic UnitServer not found"
    exit 1
fi
check_proc_then_kill "$USNAME"
if run_proc "$CHAOS_PREFIX/bin/$USNAME --log-on-file --log-file $CHAOS_PREFIX/log/UnitServer.log --unit_server_alias TEST_UNIT_0 --unit_server_enable true > /dev/null 2>&1 &" "$USNAME"; then
    ok_mesg "Generic UnitServer started"
else
    nok_mesg "Generic UnitServer started"
    exit 1
fi
sleep 2
cnt=20
ok=0
info_mesg "checking for CU registration"
while (((cnt > 0) && (ok==0) ));do
    if grep -o "TEST_UNIT_0\/TEST_CU_0 .\+ registered" $CHAOS_PREFIX/log/UnitServer.log > /dev/null;then
	ok=1
    else
	echo -n "."
    fi
    sleep 1
    ((cnt++))
done
echo

if [ $ok -eq 0 ]; then 
    nok_mesg "Generic UnitServer registered"
    exit 1
else
    ok_mesg "Generic UnitServer registered"
fi
    

