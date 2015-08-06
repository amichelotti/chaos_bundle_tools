#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
## test local services (MDS,CDS) and test configuration generation
## prepare a local random configuration for
## 10 US and 20 CU
./test-services.sh 2 10 "powersupply BasicSensor" || exit 1


## start 5 US (UnitServer) and 10 CU point to local configured metadata server
## start cus
## performs cycles of init,start,stop,deinit
## leave the CUs in start (to verify memory occupation)
##
## ./test-basic-core.sh 2 10 localhost:5000 UnitServer NOISE || exit 1
./test-basic-core.sh 2 10 localhost:5000 UnitServer || exit 1

## prepare a configuration of sensors

./test-services.sh 2 10 "sensors" || exit 1

## start 2 US (UnitServer) and 10 CU point to local configured metadata server
## start cus
## performs dedicated test on sensors

./test-sensors.sh 2 10 localhost:5000 UnitServer 60 || exit 1


## prepare a configuration of powersupplies

./test-services.sh 2 10 "powersupply" || exit 1
## start 2 US (UnitServer) and 10 CU point to local configured metadata server
## start cus
## performs dedicated test on powersupply 

./test-powersupply.sh 2 10 localhost:5000 UnitServer|| exit 1


./test-history.sh 2 10 localhost:5000 || exit 1

