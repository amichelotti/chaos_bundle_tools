#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
rm -rf $CHAOS_PREFIX/vfs
mkdir $CHAOS_PREFIX/vfs
## test local services (MDS,CDS) and test configuration generation
## prepare a local random configuration for
## 2 US and 10 CU and CDS MODE 1 
../test-local-services/test-services.sh 2 10 "benchmark" 1 || exit 1
./test-ping-bandwidth.sh 1 52 $CHAOS_MDS 524288 UnitServer || exit 

##    ./test-ping-bandwidth.sh 1 1 $CHAOS_MDS 1048576 MessMonitor || exit 
$CHAOS_PREFIX/tools/chaos_services.sh stop webui

if run_proc "$CHAOS_PREFIX/bin/misc/testDataSetIO --metadata-server $CHAOS_MDS --points 0 --pointmax 20000 --pointincr 2 --report $CHAOS_PREFIX/log/testDataSetIO.csv --loop 1000 --log-on-file 1 --log-file $CHAOS_PREFIX/log/testDataSetIO.log --direct-io-client-kv-param=ZMQ_RCVTIMEO:600000
" "testDataSetIO";then
    ok_mesg "testDataSetIO"
    pushd $CHAOS_PREFIX/log
    if gnuplot < $CHAOS_PREFIX/etc/testio.gnuplot ;then
		info_mesg "generated " " $CHAOS_PREFIX/log/testDataSetIO.png"
	fi
    popd
else
    nok_mesg "testDataSetIO"
fi
rm -rf $CHAOS_PREFIX/vfs
mkdir $CHAOS_PREFIX/vfs
