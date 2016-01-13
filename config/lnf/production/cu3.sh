#!/bin/bash
ulimit -u unlimited
separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

prefix_tmp=$dir/../../../
source $dir/../../common_util.sh


if [ -z "$CHAOS_PREFIX" ];then
    echo "%% NO environment CHAOS_PREFIX defined, setting $prefix_tmp"
    export CHAOS_PREFIX=$prefix_tmp
fi

export LD_LIBRARY_PATH=$CHAOS_PREFIX/lib
info_mesg "using prefix " "$CHAOS_PREFIX"
check_proc_then_kill BPMSync
check_proc_then_kill daqLiberaServer
check_proc_then_kill UnitServer    
procid=()
cuid=()


if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer TEST_UNIT;then
    ok_mesg "US TEST_UNIT $!"
    procid+=($!)
    cuid+=("TEST_UNIT")
else
    nok_mesg "TEST_UNIT"
    exit 1
fi




info_mesg "monitoring cus"
monitor_processes $procid $cuid
