#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
MDS_HOME=$CHAOS_PREFIX/chaosframework/ChaosMDSLite/
rm $MDS_HOME/mds_init.conf*

start_services || exit 1

if execute_command_until_ok "grep -o \"with url:.\+\" $PREFIX/log/cds.log  |sed 's/with url: //g'" 15; then
    ok_mesg "CDS on $execute_command"
else
    nok_mesg "CDS not bind a valid url"
    exit 1
fi

if ! build_mds_conf 1 1 $MDS_HOME/mds_init.conf "$execute_command" > /dev/null; then
    nok_mesg "MDS configuration created"
    exit 1
else
    ok_mesg "MDS configuration created"
fi

start_mds || exit 1

status=0

if execute_command_until_ok "wget localhost:8080/ChaosMDSLite -P wget_test1 >& /dev/null" 10 ;then
    ok_mesg "MDS answer"
else
    nok_mesg "MDS answer"
    ((status++))
fi
if execute_command_until_ok "wget localhost:8081/CU?dev=test -P wget_test1 >& /dev/null" 10 ;then
    ok_mesg "CUI answer"
else
    nok_mesg "CUI answer"
    ((status++))
fi
sleep 1

if execute_command_until_ok "[ -f \"$MDS_HOME/mds_init.conf.loaded\" ]" 10 ;then
    ok_mesg "MDS configuration loaded"
else
    nok_mesg "MDS configuration loaded"
    ((status++))
fi

rm -rf wget_test1
exit $status



