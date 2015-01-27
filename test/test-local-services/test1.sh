#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
MDS_HOME=$CHAOS_PREFIX/chaosframework/ChaosMDSLite/
rm $MDS_HOME/mds_init.conf*
if ! build_mds_conf 1 1 $MDS_HOME/mds_init.conf ; then
    nok_mesg "MDS configuration created"
    exit 1
else
    ok_mesg "MDS configuration created"
fi

start_services || exit 1
sleep 5
status=0


wget localhost:8080/ChaosMDSLite -P wget_test1 >& /dev/null
if wget localhost:8080/ChaosMDSLite -P wget_test1 >& /dev/null ;then
    ok_mesg "MDS answer"
else
    nok_mesg "MDS answer"
    ((status++))
fi
if wget localhost:8081/CU?dev=test -P wget_test1 >& /dev/null ;then
    ok_mesg "CUI answer"
else
    nok_mesg "CUI answer"
    ((status++))
fi
sleep 1
if [ -f "$MDS_HOME/mds_init.conf.loaded" ];then
    ok_mesg "MDS configuration loaded"
else
    nok_mesg "MDS configuration loaded"
    ((status++))
fi

rm -rf wget_test1
exit $status



