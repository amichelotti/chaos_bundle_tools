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

info_mesg "checking for CU registration"
if execute_command_until_ok "grep -o \"TEST_UNIT_0\/TEST_CU_0 .\+ registered\" $CHAOS_PREFIX/log/UnitServer.log > /dev/null" 30; then
    ok_mesg "Generic UnitServer registered"
else
    nok_mesg "Generic UnitServer registered"
    exit 1
fi
    

