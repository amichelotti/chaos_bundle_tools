#!/bin/bash

separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

source $dir/../common_util.sh

if [ -z "$CHAOS_PREFIX" ];then
    echo "## NO environment CHAOS_PREFIX defined"
    exit 1
fi
export LD_LIBRARY_PATH=$CHAOS_PREFIX/lib
check_proc_then_kill daqLiberaServer
check_proc_then_kill BPMSync
for k in LIBERA01 LIBERA02 LIBERA03 LIBERA07 LIBERA08 LIBERA09; do
    if launch_us_cu 1 2 localhost:5000 daqLiberaServer $k;then
	ok_mesg "US $k"
    else
	nok_mesg "US $k"
	exit 1
    fi
done
if launch_us_cu 1 1 localhost:5000 BPMSync ACCUMULATOR/BPM;then
    ok_mesg "US BPMsync"
else
    nok_mesg "US BPMSync"
    exit 1
    
fi


