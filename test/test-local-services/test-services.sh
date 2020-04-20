#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
start_test
MDS_TEST_CONF=$CHAOS_PREFIX/etc/mds_test_conf.cfg
NUS=10
NCU=20
TESTCU=""
CDSMODE="3"
SERVER="localhost:8081"
if [ -n "$CHAOS_WEBUI" ];then
    info_mesg "setting webui to " "$CHAOS_WEBUI"
    SERVER=$CHAOS_WEBUI
fi

if [ -n "$1" ];then
    NUS=$1
fi
if [ -n "$2" ];then
    NCU=$2
fi
if [ -n "$3" ];then
    TESTCU="$3"
fi

if [ -n "$4" ];then
    CDSMODE="$4"
fi
# rm $CHAOS_PREFIX/etc/cds.cfg


 # if [ "$CDSMODE" == 1 ];then
 #     cp $CHAOS_PREFIX/etc/cds_noidx.cfg $CHAOS_PREFIX/etc/cds.cfg
 # else
 #     cp $CHAOS_PREFIX/etc/cds_local.cfg $CHAOS_PREFIX/etc/cds.cfg
    
 # fi


info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU on $TESTCU"
start_services || end_test 1 "cannot start services"

cds_url="$execute_command"
# info_mesg "Building " "configuration for $TESTCU"
# if ! build_mds_conf $NCU $NUS $MDS_TEST_CONF "$cds_url" "TEST_CU" "$TESTCU"; then
#     if [ -e $CHAOS_TOOLS/../config/localhost/MDSConfig.json ]; then
# 	info_mesg "using configuration " "$CHAOS_TOOLS/../config/localhost/MDSConfig.json"
# 	MDS_TEST_CONF=$CHAOS_TOOLS/../config/localhost/MDSConfig.json
#     else
# 	nok_mesg "MDS configuration created with cds url:$cds_url"
# 	end_test 1 "MDS configuration"
#     fi
# else
#     ok_mesg "MDS configuration created with cds url:$cds_url"
# fi


if [ -e "$CHAOS_PREFIX/etc/localhost/chaosDashboard.json" ];then
    MDS_TEST_CONF=$CHAOS_PREFIX/etc/localhost/chaosDashboard.json
    ok_mesg "found $CHAOS_PREFIX/etc/localhost/chaosDashboard.json"
else
    nok_mesg "cannot find $CHAOS_PREFIX/etc/localhost/chaosDashboard.json"
    end_test 1 "Cannot find MDS_TEST_CONF"
fi

 if jchaosctl --server $SERVER --upload $MDS_TEST_CONF > $CHAOS_PREFIX/log/jchaosctl.transfer.std.out 2>&1;then
 else
    nok_mesg "Transfer test configuration \"$MDS_TEST_CONF\" to MDS"
    end_test 1 "trasfering configuration"
fi   

status=0

info_mesg "Testing REST Server $SERVER"

if jchaosctl --server $SERVER --find cu;;then 
	ok_mesg "REST answer"
else
	nok_mesg "REST answer"
    end_test 1 "search failed"

fi
sleep 1


# check_proc_then_kill "ChaosWANProxy"
# sleep 1
# echo "log-on-console=YES" > $CHAOS_PREFIX/etc/WanProxy.conf
# echo "log-level=debug" >> $CHAOS_PREFIX/etc/WanProxy.conf
# echo "cds-addresses=$cds_url">> $CHAOS_PREFIX/etc/WanProxy.conf
# echo "metadata-server=localhost:5000">> $CHAOS_PREFIX/etc/WanProxy.conf
# echo "wi-interface=HTTP" >> $CHAOS_PREFIX/etc/WanProxy.conf
# echo "wi-json-param={\"HTTP_wi_port\":8082}" >> $CHAOS_PREFIX/etc/WanProxy.conf

# if run_proc "$CHAOS_PREFIX/bin/ChaosWANProxy $CHAOS_OVERALL_OPT --conf-file $CHAOS_PREFIX/etc/WanProxy.conf > $CHAOS_PREFIX/log/ChaosWANProxy.log 2>&1 &" "ChaosWANProxy";then
#     ok_mesg "WAN Proxy started"
# else
#     nok_mesg "WAN Proxy started"
# fi
# rm -rf wget_test1
# check_proc ChaosDataService || end_test 1 "ChaosDataService not running"
if [ -z $CHAOS_WEBUI ];then
    check_proc webui || end_test 1 "webui not running"
fi
# check_proc ChaosWANProxy || end_test 1 "ChaosWANProxy not running"

# info_mesg "performing test pushing on webui " "CREST CU"
# if [ $OS == "Darwin" ];then
#     info_mesg " CREST test disabled on " " Darwin"
# else
    
#     if $CHAOS_PREFIX/bin/crest_test localhost:8081 10000 > $CHAOS_PREFIX/log/crest_test.log ;then
#     ok_mesg "CREST CU TEST"
#     cat $CHAOS_PREFIX/log/crest_test.log |grep average
#     else
# 	nok_mesg "CREST CU TEST"
# 	end_test 1 "CREST CU TEST"
#     fi
# fi
# info_mesg "performing test retriving from webui " "CREST UI"
# if $CHAOS_PREFIX/bin/chaos_crest_ui_test localhost:8081 "BTF_SIM/QDC0" > $CHAOS_PREFIX/log/crest_ui_test.log ;then
#     ok_mesg "CREST UI TEST"
# else
#     nok_mesg "CREST UI TEST"
#     end_test 1 "CREST UI TEST"
# fi

end_test 0



