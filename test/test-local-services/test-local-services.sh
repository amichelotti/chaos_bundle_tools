#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
## test local services (MDS,CDS) and test configuration generation
## prepare a local random configuration for
## 10 US and 20 CU
./test-services.sh 10 20 || exit 1


## start 5 US (UnitServer) and 10 CU point to local configured metadata server
## start cus
## performs cycles of init,start,stop,deinit
## leave the CUs in start (to verify memory occupation)
##
./test-basic-core.sh 5 10 localhost:5000 UnitServer|| exit 1

## start 2 US (UnitServer) and 10 CU point to local configured metadata server
## start cus
## performs dedicated test on powersupply 

./test-powersupply.sh 2 10 localhost:5000 UnitServer|| exit 1
