#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
start_test
MDS_HOME=$CHAOS_PREFIX/chaosframework/ChaosMDSLite/
rm -rf $MDS_HOME/mds_init.conf* >/dev/null
NUS=10
NCU=20

if [ -n "$1" ];then
    NUS=$1
fi
if [ -n "$2" ];then
    NCU=$2
fi
info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU"
start_services || end_test 1 "cannot start services"

if execute_command_until_ok "grep -o \"with url:.\+\" $PREFIX/log/cds.log  |sed 's/with url: //g'" 15; then
    ok_mesg "CDS on $execute_command"
else
    nok_mesg "CDS not bind a valid url"
    end_test 1 "CDS not bind a valid url"
fi
info_mesg "Building " "configuration"
if ! build_mds_conf $NCU $NUS $MDS_HOME/mds_init.conf "$execute_command" "TEST_CU" ; then
    nok_mesg "MDS configuration created"
    end_test 1 "MDS configuration"
else
    ok_mesg "MDS configuration created"
fi

start_mds || end_test 1 "Starting MDS"

status=0

if execute_command_until_ok "wget localhost:8080/ChaosMDSLite -P wget_test1 >& /dev/null" 10 ;then
    ok_mesg "MDS answer"
else
    nok_mesg "MDS answer"
    end_test 1 "MDS answer"
fi
if execute_command_until_ok "wget localhost:8081/CU?dev=test -P wget_test1 >& /dev/null" 10 ;then
    ok_mesg "CUI answer"
else
    nok_mesg "CUI answer"
    end_test 1 "CUI answer"
fi
sleep 1

if execute_command_until_ok "[ -f \"$MDS_HOME/mds_init.conf.loaded\" ]" 10 ;then
    ok_mesg "MDS configuration loaded"
else
    nok_mesg "MDS configuration loaded"
    end_test 1 "MDS configuration"
fi

rm -rf wget_test1
check_proc ChaosDataService || end_test 1 "ChaosDataService not running"
check_proc CUIserver || end_test 1 "CUIserver not running"
check_proc "tomcat:run" || end_test 1 "MDS not running"


end_test 0



