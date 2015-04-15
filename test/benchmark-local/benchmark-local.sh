#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
rm -rf $CHAOS_PREFIX/vfs
mkdir $CHAOS_PREFIX/vfs
## test local services (MDS,CDS) and test configuration generation
## prepare a local random configuration for
## 2 US and 10 CU
../test-local-services/test-services.sh 2 10 "chaos-mess" || exit 1
## 1 US, 1 CU, MDS, MAX BUF
./test-ping-bandwidth.sh 1 1 localhost:5000 524288 || exit 
rm -rf $CHAOS_PREFIX/vfs
mkdir $CHAOS_PREFIX/vfs
