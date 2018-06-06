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

$CHAOS_PREFIX/bin/misc/testDataSetIO --loop 1000000 --points 100 --log-on-file 1 --log-level debug --log-file $CHAOS_PREFIX/log/testDataSetIO.log

rm -rf $CHAOS_PREFIX/vfs
mkdir $CHAOS_PREFIX/vfs
