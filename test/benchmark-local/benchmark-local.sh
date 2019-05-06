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

if $CHAOS_PREFIX/tools/testio.sh -m $CHAOS_MDS -l 1000 -g -t 4;then
    ok_mesg "testio"
    mv *.png $CHAOS_PREFIX/log
else
    nok_mesg "testio"
    info_mesg "dumping " "$CHAOS_PREFIX/log/chaos_daq.json"
    mongoexport --host mongo --db chaos --collection daq --out $CHAOS_PREFIX/log/chaos_daq.json
    end_test 1 "TESTIO FAILED"
    exit 1
fi
rm -rf $CHAOS_PREFIX/vfs
mkdir $CHAOS_PREFIX/vfs
