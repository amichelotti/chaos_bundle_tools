#!/bin/bash
## test local services (MDS,CDS) and test configuration generation
## prepare a local random configuration for
## 10 US and 20 CU
./test-services.sh 10 20 || exit 1
## start 5 US and 10 CU point to local configured metadata server
## start cus
## perform cycles of init,start,stop,deinit
## leave the CUs in start (to verify memory occupation)
##
echo "Test basic core functionalities"
./test-basic-core.sh 5 10 localhost:5000 || exit 1

