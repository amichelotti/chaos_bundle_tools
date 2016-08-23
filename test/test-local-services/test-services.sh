#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
start_test
MDS_TEST_CONF=$CHAOS_PREFIX/etc/mds_test_conf.cfg
NUS=10
NCU=20
TESTCU=""
CDSMODE="3"

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

if execute_command_until_ok "grep -o \"with url:.\+\" $CHAOS_PREFIX/log/ChaosDataService.log  |sed 's/with url: //g'" 15; then
    ok_mesg "CDS on $execute_command"
else
    nok_mesg "CDS not bind a valid url"
    end_test 1 "CDS not bind a valid url"
fi
cds_url="$execute_command"
info_mesg "Building " "configuration for $TESTCU"
if ! build_mds_conf $NCU $NUS $MDS_TEST_CONF "$cds_url" "TEST_CU" "$TESTCU"; then
    if [ -e $CHAOS_TOOLS/../config/localhost/MDSConfig.txt ]; then
	info_mesg "using configuration " "$CHAOS_TOOLS/../config/localhost/MDSConfig.txt"
	MDS_TEST_CONF=$CHAOS_TOOLS/../config/localhost/MDSConfig.txt
    else
	nok_mesg "MDS configuration created with cds url:$cds_url"
	end_test 1 "MDS configuration"
    fi
else
    ok_mesg "MDS configuration created with cds url:$cds_url"
fi

start_mds || end_test 1 "Starting MDS"


if $CHAOS_PREFIX/bin/ChaosMDSCmd -r 1 $CHAOS_OVERALL_OPT --mds-conf $MDS_TEST_CONF >& $CHAOS_PREFIX/log/ChaosMDSCmd.log; then
    ok_mesg "Transfer test configuration \"$MDS_TEST_CONF\" to MDS"
else
    nok_mesg "Transfer test configuration \"$MDS_TEST_CONF\" to MDS"
    end_test 1
fi
status=0

if which wget >& /dev/null ;then 
    info_mesg "Testing UI Server"
    unset http_proxy
    if execute_command_until_ok "wget localhost:8081/CU?dev=TEST_UNIT_0/TEST_CU_0 -P wget_test1 >& /dev/null" 10 ;then
	ok_mesg "CUI answer"
    else
	nok_mesg "CUI answer"
	end_test 1 "CUI answer"
    fi
else
    info_mesg "skipping CUI test because wget is " "missing"
fi
sleep 1


check_proc_then_kill "ChaosWANProxy"
sleep 1
echo "log-on-console=YES" > $CHAOS_PREFIX/etc/WanProxy.conf
echo "log-level=debug" >> $CHAOS_PREFIX/etc/WanProxy.conf
echo "cds-addresses=$cds_url">> $CHAOS_PREFIX/etc/WanProxy.conf
echo "metadata-server=localhost:5000">> $CHAOS_PREFIX/etc/WanProxy.conf
echo "wi-interface=HTTP" >> $CHAOS_PREFIX/etc/WanProxy.conf
echo "wi-json-param={\"HTTP_wi_port\":8082}" >> $CHAOS_PREFIX/etc/WanProxy.conf

if run_proc "$CHAOS_PREFIX/bin/ChaosWANProxy $CHAOS_OVERALL_OPT --conf-file $CHAOS_PREFIX/etc/WanProxy.conf > $CHAOS_PREFIX/log/ChaosWANProxy.log 2>&1 &" "ChaosWANProxy";then
    ok_mesg "WAN Proxy started"
else
    nok_mesg "WAN Proxy started"
fi
rm -rf wget_test1
check_proc ChaosDataService || end_test 1 "ChaosDataService not running"
check_proc CUIserver || end_test 1 "CUIserver not running"
check_proc ChaosWANProxy || end_test 1 "ChaosWANProxy not running"

info_mesg "performing test pushing on ChaosWANProxy " "CREST CU"
if [ $OS == "Darwin" ];then
    info_mesg " CREST test disabled on " " Darwin"
else
    
    if $CHAOS_PREFIX/bin/crest_test localhost:8082 10000 > $CHAOS_PREFIX/log/crest_test.log ;then
    ok_mesg "CREST CU TEST"
    cat $CHAOS_PREFIX/log/crest_test.log |grep average
    else
	nok_mesg "CREST CU TEST"
	end_test 1 "CREST CU TEST"
    fi
fi
# info_mesg "performing test retriving from CUIserver " "CREST UI"
# if $CHAOS_PREFIX/bin/chaos_crest_ui_test localhost:8081 "BTF_SIM/QDC0" > $CHAOS_PREFIX/log/crest_ui_test.log ;then
#     ok_mesg "CREST UI TEST"
# else
#     nok_mesg "CREST UI TEST"
#     end_test 1 "CREST UI TEST"
# fi

end_test 0



