#!/bin/bash
source $CHAOS_TOOLS/common_util.sh

USNAME=UnitServer
NUS=5
NCU=10
META="localhost:5000"
if [ -n "$1" ];then
    NUS=$1
fi
if [ -n "$2" ];then
    NCU=$2
fi
if [ -n "$3" ];then
    META="$3"
fi
if [ -n "$4" ];then
    USNAME="$4"
fi

info_mesg "Noise \"$0\" with:" "NUS:$NUS,NCU:$NCU,METADATASERVER:$META"

while(true);do
    for ((us=0;us<$NUS;us++));do
	for ((cu=0;cu<$NCU;cu++));do
	    $CHAOS_PREFIX/bin/ChaosCLI --metadata-server="$META" --deviceid "TEST_UNIT_$us/TEST_CU_$cu" --timeout 100 --op 1 2>&1
	done
    done
done

